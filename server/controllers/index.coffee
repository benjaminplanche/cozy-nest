module.exports.main = (req, res) ->
    res.send 200, message: 'Hello, world!'
	
/*
 * ------------------------------------------
 * SENSORS - CRUD Services
 * ------------------------------------------
 */
 
/**
 * createSensor
 * ====
 * Add a sensor to the DB and system, if there is a driver to handle it.
 * Parameters:
 *	- type (String): 					Type of sensor
 *  - name (String): 					Human-readable name	
 *	- customId (String): 				Custom ID for the driver
 *	- cb (Function(Erreur, int)):		Callback
 */
function createSensor(type, name, customId, baseAddr, cb) {
	if (sensorsDrivers[type]) { // If this kind of device is supported:
		if(baseAddr) { customId += '+'+baseAddr; }
		// Check if this sensor isn't already added (the combination type + customId should be unique):
		models.Sensor.findOrCreate({ customId: customId, type: type }, { name: name })
			.success(function(sensor, created) {
				if (!created) {
					cb('Device already added', sensor.id);
					return;
				}
				// Let the driver handle the integration of the device to the system:
				sensorsDrivers[type].add(customId, sensor.id, function(err){
					if (err) { // Cancelling Modif:
						models.Sensor.destroy({id: sensor.id})
							.success(function() {
								cb(err, null);
								return;
							});
					}
					else cb(null, sensor.id);
				});
			})
			.error(function(err) {
				cb(err, null);
			});
		
	} else {
		cb('Device not supported', null);
	}
}
/**
 * serviceCreateSensor
 * ====
 * Request Var:
 * 		none
 * Request Parameters:
 * 		- type (String): 					Type of sensor				                - required
 * 		- name (String): 					Human-readable name			                - required
 *		- customId (String): 				Custom ID for the driver 	                - required
 *		- baseStationUrl (String): 			Address where the base station is running	- required
 */
function serviceCreateSensor(req, resp) {
	logger.info("<Service> CreateSensor.");
	var sensorData = parseRequest(req, ['type', 'customId', 'name', 'baseAddr']);
	
	writeHeaders(resp);
	createSensor(sensorData.type, sensorData.name, sensorData.customId, sensorData.baseAddr, function(err, id) {
		if (err) { error(10, resp, err); return; }
		resp.end(JSON.stringify({ status: 'ok', id: id }));
	});
}
 
/**
 * getSensors
 * ====
 * Returns a list of sensors.
 * Parameters:
 *	- type (String): 					Type of sensor to find
 *	- customId (String): 				Custom ID to find
 *	- limit (int): 					Number max of sensors to return
 *	- offset (int): 				Number of the sensor to start with
 *	- cb (Function(err, Sensor[])):	Callback
 */
function getSensors(type, customId, limit, offset, cb) {
	if (!offset) offset = 0;
	var conditions = {};
	if (type) { condition.type = type; }
	if (customId) { condition.customId = customId; }
	
	if (limit) {
		models.Sensor.findAll({ where: conditions, offset: offset, limit: limit, raw: true })
			.success(function(ans){cb(null, ans);})
			.error(function(err) {
				cb(err, null);
			});
	}
	else {
		models.Sensor.findAll({ where: conditions, offset: offset, raw: true })
			.success(function(ans){cb(null, ans);})
			.error(function(err) {
				cb(err, null);
			});
	}
}
/**
 * serviceGetSensors
 * ====
 * Request Var:
 * 		none
 * Request Parameters:
 *		- type (String): 		Type of sensor to find				- optional
 *		- customId (String): 	Custom ID to find					- optional
 *		- limit (int): 			Number max to return				- optional
 *		- offset (int): 		Number of the sensor to start with	- optional
 */
function serviceGetSensors(req, resp) {
	logger.info("<Service> GetSensors.");
	var getData = parseRequest(req, ['limit', 'offset', 'type', 'customId']);
	
	writeHeaders(resp);
	getSensors(getData.type, getData.customId, getData.limit, getData.offset, function (err, sensors) {
		if (err) { error(2, resp, err); return; }
		resp.end(JSON.stringify({ sensors: sensors })); 
	});
}	
 

/*
 * ------------------------------------------
 * SENSOR Services
 * ------------------------------------------
 */
 
/**
 * getSensor
 * ====
 * Returns the Sensor corresponding to the given id
 * Parameters:
 *	- id (int): 					Id
 *	- cb (Function(Sensor)):	Callback
 */
function getSensor(id, cb) {
	models.Sensor.find(id)
		.success(function(ans){cb(null, ans);})
		.error(function(err) {
			cb(err, null);
		});
}
/**
 * serviceGetSensor
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		-none
 */
function serviceGetSensor(req, resp) {
	logger.info("<Service> GetSensor.");
	var getData = parseRequest(req, ['id']);
	
	writeHeaders(resp);
	getSensor(getData.id, function(err, sensor) {
		if (err) { error(2, resp, err); return; }
		resp.end(JSON.stringify({ sensor: (sensor?sensor.values:null) })); 
	});
}
 
/**
 * getSensorType
 * ====
 * Returns the Sensor's type
 * Parameters:
 *	- id (String): 				ID
 *	- cb (Function(err, type):	Callback
 */
function getSensorType(id, cb) {
	models.Sensor.find(id)
		.success(function(sensor){
			cb(null, sensor.type);
		})
		.error(function(err) {
			cb(err, null);
		});
}
/**
 * serviceGetSensorType
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		-none
 */
function serviceGetSensorType(req, resp) {
	logger.info("<Service> GetSensorType.");
	var getData = parseRequest(req, ['id']);
	
	writeHeaders(resp);
	getSensorType(getData.id, function(err, type) {
		if (err) { error(2, resp, err); return; }
		resp.end(JSON.stringify({ type: type })); 
	});
}

/**
 * getSensorName
 * ====
 * Returns the Sensor's name
 * Parameters:
 *	- id (String): 				ID
 *	- cb (Function(err, name):	Callback
 */
function getSensorName(id, cb) {
	models.Sensor.find(id)
		.success(function(sensor){
			cb(null, sensor.name);
		})
		.error(function(err) {
			cb(err, null);
		});
}
/**
 * serviceGetSensorName
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		-none
 */
function serviceGetSensorName(req, resp) {
	logger.info("<Service> GetSensorName.");
	var getData = parseRequest(req, ['id']);
	
	writeHeaders(resp);
	getSensorName(getData.id, function(err, name) {
		if (err) { error(2, resp, err); return; }
		resp.end(JSON.stringify({ name: name })); 
	});
}

/**
 * getSensorCustomId
 * ====
 * Returns the Sensor's customId
 * Parameters:
 *	- id (String): 				ID
 *	- cb (Function(err, customId):	Callback
 */
function getSensorCustomId(id, cb) {
	models.Sensor.find(id)
		.success(function(sensor){
			cb(null, sensor.customId);
		})
		.error(function(err) {
			cb(err, null);
		});
		
}
/**
 * serviceGetSensorCustomId
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		-none
 */
function serviceGetSensorCustomId(req, resp) {
	logger.info("<Service> GetSensorCustomId.");
	var getData = parseRequest(req, ['id']);
	
	writeHeaders(resp);
	getSensorCustomId(getData.id, function(err, customId) {
		if (err) { error(2, resp, err); return; }
		resp.end(JSON.stringify({ customId: customId })); 
	});
}

/**
 * deleteSensor
 * ====
 * Delete the Sensor corresponding to the given id
 * Parameters:
 *	- id (String): 			ID
 *	- cb (Function(bool)):	Callback
 */
function deleteSensor(id, cb) {
	getSensor(id, function(err, prevSensor) { // Getting info for driver
		if (err) { error(2, resp, err); return; }
		sensorsDrivers[prevSensor.type].remove(prevSensor.customId, function(err){
			if (err) {
				cb(err, null);
				return;
			}
			// Remove from DB:
			models.Sensor.destroy({id: id})
				.success(function() {
					cb(null, true);
				})
				.error(function(err1) { // Cancelling Modif:
					sensorsDrivers[prevSensor.type].add(prevSensor.customId, id, function(err2){
						if (err2) {
							cb('Device removed from system but not DB. Contact Admin', null);
							return;
						}
						cb(err1, null);
					});
				});
		});
	});
}
/**
 * serviceDeleteSensor
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		-none
 */
function serviceDeleteSensor(req, resp) {
	logger.info("<Service> DeleteSensor.");
	var getData = parseRequest(req, ['id']);
	
	writeHeaders(resp);
	deleteSensor(getData.id, function (err, bool) {
		if (err) { error(2, resp, err); return; }
		if (!bool) error(2, resp);
		else resp.end(JSON.stringify({ status: 'ok' })); 
	});
}

/**
 * updateSensor
 * ====
 * Update the Sensor corresponding to the given id
 * Parameters:
 *	- type (String): 			Type of sensor
 * 	- name (String):			Human-readable name
 *	- customId (String): 		Custom ID for the driver
 *	- cb (Function(bool)):		Callback
 */ 
function updateSensor(id, type, name,customId, cb) {
	if (sensorsDrivers[type]) { // If this kind of device is supported:
		getSensor(id, function(err, prevSensor) { // Getting previous customId to inform the Driver of the update:
			if (err) { error(2, resp, err); return; }
			// Add to DB:
			models.Sensor.update({type: type, customId: customId, name:name}, {id: id})
				.success(function() {
					// Inform the driver of the change:
					sensorsDrivers[type].update(prevSensor.customId, customId, function(err){
							if (err) { // Cancelling Modif:
								models.Sensor.update({type: prevSensor.type, customId: prevSensor.customId}, {id: id})
									.success(function() {
										cb(err, null);
										return;
									});
							}
							else cb(null, true);
						});
				})
				.error(function(err) {
					cb(err, null);
				});
		});
		
	} else {
		cb('Device not supported', null);
	}
}
/**
 * serviceUpdateSensor
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 * 		- type (String): 					Type of sensor				- required
 * 		- name (String):					Human-readable name			- required
 *		- customId (String): 				Custom ID for the driver 	- required
 */
function serviceUpdateSensor(req, resp) {
	logger.info("<Service> UpdateSensor.");
	var sensorData = parseRequest(req, ['id', 'type', 'customId', 'name']);
	
	writeHeaders(resp);
	updateSensor(sensorData.id, sensorData.type, sensorData.name, sensorData.customId, function(err, bool) {
		if (err) { error(2, resp, err); return; }
		if (!bool) error(2, resp);
		else resp.end(JSON.stringify({ status: 'ok' })); 
	});
}
	
/**
 * updateSensorType
 * ====
 * Update the type of the Sensor corresponding to the given id
 * Parameters:
 *	- id (String): 				ID
 *	- type (String): 			Type to change
 *	- cb (Function(bool):		Callback
 */ 
function updateSensorType(id, type, cb) {
		models.Sensor.update({type: type}, {id: id})
		.success(function() {
			cb(null, true);
		})
		.error(function(err) {
			cb(err, null);
		});
}
/**
 * serviceUpdateSensorType
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		- type (String): 	Type 		- required
 */
function serviceUpdateSensorType(req, resp) {
	logger.info("<Service> UpdateSensorType.");
	var sensorData = parseRequest(req, ['id', 'type']);
	
	writeHeaders(resp);
	updateSensorType(sensorData.id, sensorData.type, function(err, bool) {
		if (!bool) error(2, resp);
		else resp.end(JSON.stringify({ status: 'ok' })); 
	});
}

/**
 * updateSensorName
 * ====
 * Update the name of the Sensor corresponding to the given id
 * Parameters:
 *	- id (String): 				ID
 *	- name (String): 			Name to change
 *	- cb (Function(bool):		Callback
 */ 
function updateSensorName(id, name, cb) {
		models.Sensor.update({name: name}, {id: id})
		.success(function() {
			cb(null, true);
		})
		.error(function(err) {
			cb(err, null);
		});
}
/**
 * serviceUpdateSensorName
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		- name (String): 	Name 		- required
 */
function serviceUpdateSensorName(req, resp) {
	logger.info("<Service> UpdateSensorName.");
	var sensorData = parseRequest(req, ['id', 'name']);
	
	writeHeaders(resp);
	updateSensorName(sensorData.id, sensorData.name, function(err, bool) {
		if (!bool) error(2, resp);
		else resp.end(JSON.stringify({ status: 'ok' })); 
	});
}

/**
 * updateSensorCustomId
 * ====
 * Update the customId of the Sensor corresponding to the given id
 * Parameters:
 *	- id (String): 				ID
 *	- customId (String): 			CustomId to change
 *	- cb (Function(bool):		Callback
 */ 
function updateSensorCustomId(id, customId, cb) {
	getSensor(id, function(err, prevSensor) { // Getting previous customId to inform the Driver of the update:
		if (err) { error(2, resp, err); return; }
			// Add to DB:
			models.Sensor.update({type: type, customId: customId}, {id: id})
				.success(function() {
					// Inform the driver of the change:
					sensorsDrivers[prevSensor.type].update(prevSensor.customId, customId, function(err){
							if (err) { // Cancelling Modif:
								models.Sensor.update({customId: prevSensor.customId}, {id: id})
									.success(function() {
										cb(err, null);
										return;
									});
							}
							else cb(null, true);
						});
				})
				.error(function(err) {
					cb(err, null);
				});
	});
}
/**
 * serviceUpdateSensorCustomId
 * ====
 * Request Var:
 * 		- id (string)		ID
 * Request Parameters:
 *		- customId (String): 	CustomId 		- required
 */
function serviceUpdateSensorCustomId(req, resp) {
	logger.info("<Service> UpdateSensorCustomId.");
	var sensorData = parseRequest(req, ['id', 'customId']);
	
	writeHeaders(resp);
	updateSensorCustomId(sensorData.id, sensorData.customId, function(err, bool) {
		if (err) { error(2, resp, err); return; }
		if (!bool) error(2, resp);
		else resp.end(JSON.stringify({ status: 'ok' })); 
	});
}	