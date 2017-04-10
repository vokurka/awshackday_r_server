var http = require('http');
var options = {
  hostname: '54.255.249.240',
  port: 80,
  path: '/?type=washingmachine',
  method: 'GET'
};

var request = http.request(options);

request.on('response', function( res ) {
	var body = '';
    res.on('data', function( data ) {
        //speechOutput = data.toString();
        //console.log(speechOutput);
        body += data;
    } );

    res.on('end', function() {
    	speechOutput = body.toString();
    	
    	console.log(body);
    });
} );
request.end();