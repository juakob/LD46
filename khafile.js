let project = new Project('LD46');

//project.addDefine('debugInfo');
//project.addDefine('DEBUGDRAW');

project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');
await project.addProject('khawy');
project.addLibrary('tiled');
project.addDefine('analyzer-optimize');
project.addParameter('-dce full');
project.targetOptions.html5.disableContextMenu = true;

if (process.argv.includes("--watch")) {
	let libPath = project.addLibrary('hotml');
	project.addDefine('js_classic');
	const path = require('path');
	if (!libPath) libPath = path.resolve('./Libraries/hotml');
	const Server = require(`${libPath}/bin/server.js`).hotml.server.Main;
	const server = new Server(`${path.resolve('.')}/build/${platform}`, 'kha.js');
	callbacks.postHaxeRecompilation = () => {
		server.reload();
	}
	callbacks.postAssetReexporting = (path) => {
		server.reloadAsset(path);
	}
}

resolve(project);
