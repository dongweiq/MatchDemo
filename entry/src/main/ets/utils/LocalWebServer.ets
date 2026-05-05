import { HttpServer } from '@cxy/webserver';
import { socket } from '@kit.NetworkKit';
import { justReadRawFileSync } from './common/filecenter/FileUtils';
import { GlobalContext } from './common/GlobalContext';
import fs from '@ohos.file.fs';
import { JSON } from '@kit.ArkTS';

export class LocalWebServer {

  private static instance: LocalWebServer;

  private server: HttpServer;

  private serverResourcePath: string = '';

  public ip: string = '';

  public port: number = 8081;

  private constructor() {
    this.server = new HttpServer();
  }

  public static getInstance(): LocalWebServer {
    if (LocalWebServer.instance === undefined) {
      LocalWebServer.instance = new LocalWebServer();
    }
    return LocalWebServer.instance;
  }

  public start(): Promise<void> {
    return new Promise((resolve) => {
      this.server.startServer(8081)
        .then((startInfo: socket.NetAddress) => {
          this.ip = startInfo.address;
          this.port = startInfo.port as number ?? 8081
          this.configuration();
          resolve();
        });
    });
  }

  public stop() {
    this.server.stopServer();
  }

  private configuration() {
    this.server.logger({
      stream: (log: string) => console.log(log)
    })
    this.server.cors(); // 支持跨域。
    this.server.auto(); //自动解析。
    this.serverResourcePath = GlobalContext.getContext()?.filesDir + '/www';
    this.server.serveStatic(this.serverResourcePath);
    this.prepareResource();
    this.prepareIndexFile();
  }

  private prepareResource() {
    try {
      // 创建资源目录。
      if (!fs.accessSync(this.serverResourcePath, fs.AccessModeType.EXIST)) {
        fs.mkdirSync(this.serverResourcePath);
      }
      // 写入threeJS。
      let threeFile = fs.openSync(this.serverResourcePath + '/three.module.js', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let threeFileContent = justReadRawFileSync('classroom/includes/three.module.js');
      fs.writeSync(threeFile.fd, threeFileContent);
      fs.closeSync(threeFile);
      // 写入PhotoSphereViewerJS。
      let sphereFile = fs.openSync(this.serverResourcePath + '/photoSphereViewerCore.index.module.js', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let sphereFileContent = justReadRawFileSync('classroom/includes/photoSphereViewerCore.index.module.js');
      fs.writeSync(sphereFile.fd, sphereFileContent);
      fs.closeSync(sphereFile);
      // 写入normalizeCss。
      let normalCssFile = fs.openSync(this.serverResourcePath + '/normalize.css', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let normalCssFileContent = justReadRawFileSync('classroom/styles/normalize.css');
      fs.writeSync(normalCssFile.fd, normalCssFileContent);
      fs.closeSync(normalCssFile);
      // 写入photoSphereViewerCoreCss。
      let sphereCssFile = fs.openSync(this.serverResourcePath + '/photoSphereViewerCore.index.min.css', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let sphereCssFileContent = justReadRawFileSync('classroom/styles/photoSphereViewerCore.index.min.css');
      fs.writeSync(sphereCssFile.fd, sphereCssFileContent);
      fs.closeSync(sphereCssFile);

    } catch (error) {
    }
  }

  private prepareIndexFile() {
    try {
      let indexFileContent = `
<!doctype html>
<html lang="zh-cn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="http://${this.ip}:${this.port}/normalize.css" />
    <link rel="stylesheet" href="http://${this.ip}:${this.port}/photoSphereViewerCore.index.min.css" />

</head>
<body>
<div id="viewer" style="width: 100vw; height: 100vh;"></div>
<script type="importmap">
    {
        "imports": {
            "three": "http://${this.ip}:${this.port}/three.module.js",
            "@photo-sphere-viewer/core": "http://${this.ip}:${this.port}/photoSphereViewerCore.index.module.js"
        }
    }
</script>

<script type="module">
    import { Viewer } from '@photo-sphere-viewer/core';

    const viewer = new Viewer({
        container: document.querySelector('#viewer'),
        panorama: 'https://photo-sphere-viewer-data.netlify.app/assets/sphere.jpg',
        crossorigin: 'anonymous',
        loadingMode: 'mono',
        navbar: false
    });
</script>
</body>
</html>
      `;
      let indexFile = fs.openSync(this.serverResourcePath + '/index.html', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(indexFile.fd, indexFileContent);
      fs.closeSync(indexFile);
    } catch (error) {
      console.log(`state === 异常：${JSON.stringify(error)}`);
    }
  }
}