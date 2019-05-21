# MetalCanvas

[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Xcode 10.2+](https://img.shields.io/badge/Xcode-10.2+-blue.svg?style=flat)](https://developer.apple.com/swift/)



## 概要

このフレームワークはprocessingの思想を基にしています。
processingにおけるOpenGLのように、Metalを少ないインターフェースで使えることを目指しています。
少ないコードで キャンバスに絵を描くようにコードで絵を描きます。
点や四角などのプリミティブの描画や画像処理。
そういった事を簡単に行なえます。

---

Processing is a flexible software sketchbook and a language for learning how to code within the context of the visual arts. Since 2001, Processing has promoted software literacy within the visual arts and visual literacy within technology. There are tens of thousands of students, artists, designers, researchers, and hobbyists who use Processing for learning and prototyping.

---

#### 参考

* [processing](https://processing.org/)
* [openframeworks](https://openframeworks.cc/)
* [Flash BitmapData](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/BitmapData.html)


#### Metal学習参考

* [Metal Programming Guide](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html
)
* [Metalを基礎から日本語で学べる書籍](https://qiita.com/shu223/items/19c7d98fc186562b4f57)


## サンプルコード

```
import UIKit
import MetalCanvas

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		do {
			// 初期化
			try MCCore.setup(contextPptions: [
				CIContextOption.workingColorSpace : CGColorSpaceCreateDeviceRGB(),
				CIContextOption.useSoftwareRenderer : NSNumber(value: false)
				])
		} catch {
			
		}
		return true
	}

```

```
do {
	// MTLCommandBufferを生成
	var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer()!
	
	// キャンバスを生成
	let canvas: MCCanvas = try MCCanvas.init(destination: &destinationTexture, orthoType: .topLeft)
	
	// キャンバスにプリミティブを描画
	try canvas.draw(commandBuffer: &commandBuffer, objects: [
	
		// キャンバスにポイントを描画
		MCPoint.init(
			ppsition: MCGeom.Vec3D.init(x: 0, y: 0, z: 0),
			color: MCColor.init(hex: "0xFF0000"), size: 200.0
		),
		MCPoint.init(
			ppsition: MCGeom.Vec3D.init(x: 300, y: 10, z: 0),
			color: MCColor.init(hex: "0xFFFF00"), size: 300.0
		)
	])
	
	// MCImageRenderViewを更新（描画）
	self.imageRender?.update(
		commandBuffer: commandBuffer,
		texture: destinationTexture,
		renderSize: renderSize,
		queue: nil
	)

} catch {
}
```


## サンプルコード 画像描画

* [DrawSample01VC.swift](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/Example/MetalCanvasExample/DrawSample01VC.swift)


## サンプルコード リアルタイム描画

* [DrawSample02VC.swift](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/Example/MetalCanvasExample/DrawSample02VC.swift)


## Coming Soon

* Noise
* Filter
* Morphing
* Vision



