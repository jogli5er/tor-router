
const _ = require('lodash');
const { assert } = require('chai');
const { Provider } = require('nconf');
const nconf = new Provider();
const getPort = require('get-port');

nconf.use('memory');
require(`${__dirname}/../src/nconf_load_env.js`)(nconf);		
nconf.defaults(require(`${__dirname}/../src/default_config.js`));
const { ControlServer, TorPool, HTTPServer, SOCKSServer, DNSServer } = require('../');

let controlServer = new ControlServer(nconf);
let controlPort;

describe('ControlServer', function () {
	describe('#listen(port)', function () {
		it('should bind to a given port', async function () {
			controlPort = await getPort();
			await controlServer.listen(controlPort);
		});
	});
	describe('#createTorPool(options)', function () {
		it('should create a TorPool with a given configuration', function () {
			let torPool = controlServer.createTorPool({ ProtocolWarnings: 1 });

			assert.instanceOf(controlServer.tor_pool, TorPool);
			assert.equal(1, torPool.default_tor_config.ProtocolWarnings);
		});
	});
	describe('#createSOCKSServer(port)', function () {
		it('should create a SOCKS Server', async function () {
			let port = await getPort();
			controlServer.createSOCKSServer(port);
			assert.instanceOf(controlServer.socksServer, SOCKSServer);
		});
	});
	describe('#createDNSServer(port)', function () {
		it('should create a DNS Server', async function () {
			let port = await getPort();
			controlServer.createDNSServer(port);
			assert.instanceOf(controlServer.dnsServer, DNSServer);
		});
	});
	describe('#createHTTPServer(port)', function () {
		it('should create a HTTP Server', async function () {
			let port = await getPort();
			controlServer.createHTTPServer(port);
			assert.instanceOf(controlServer.httpServer, HTTPServer);
		});
	});

	describe('#close()', function () {
		it('should close the RPC Server', function () {
			controlServer.close();
		});
	});

	after('shutdown tor pool', async function () {
		await controlServer.tor_pool.exit();
	});
});