//
//  MCTexture.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import MetalKit

#if targetEnvironment(simulator)
public struct MCTexture {}
#else
public struct MCTexture {
	public enum ErrorType: Error {
		case createError
	}
	
	public var width: Int {
		get { return texture.width }
	}
	public var height: Int {
		get { return texture.height }
	}
	public var pixelFormat: MTLPixelFormat {
		get { return texture.pixelFormat }
	}
	public fileprivate(set) var texture: MTLTexture
	public init(renderSize: CGSize) throws {
		let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.bgra8Unorm, width: Int(renderSize.width), height: Int(renderSize.height), mipmapped: true)
		textureDescriptor.usage = [.shaderRead, .shaderWrite]
		guard let texture: MTLTexture = MCCore.device.makeTexture(descriptor: textureDescriptor) else { throw ErrorType.createError }
		self.texture = texture
	}

	public init(URL: URL) throws {
		let textureLoaderOptions = [
			MTKTextureLoader.Option.SRGB: true,
			MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
			MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
		]
		self.texture = try MCCore.textureLoader.newTexture(URL: URL, options: textureLoaderOptions)
	}
	
	public init(URL: URL, commandBuffer: MTLCommandBuffer) throws {
		guard
			let inputImage: CIImage = CIImage.init(contentsOf: URL),
			let colorSpace: CGColorSpace = inputImage.colorSpace
		else { throw ErrorType.createError }
		let renderSize: CGSize = inputImage.extent.size

		//let renderSize: CGSize = CGSize.init(100, 100)
		let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
			pixelFormat: MTLPixelFormat.bgra8Unorm,
			width: Int(renderSize.width), height: Int(renderSize.height),
			mipmapped: true)
		textureDescriptor.usage = [.shaderRead, .shaderWrite]
		guard let texture: MTLTexture = MCCore.device.makeTexture(descriptor: textureDescriptor) else { throw ErrorType.createError }
		MCCore.ciContext.render(inputImage, to: texture, commandBuffer: commandBuffer, bounds: inputImage.extent, colorSpace: colorSpace)
		self.texture = texture
	}

	public init(pixelBuffer: inout CVPixelBuffer, planeIndex: Int) throws {
		try self.init(pixelBuffer: &pixelBuffer, colorPixelFormat: MTLPixelFormat.bgra8Unorm, planeIndex: planeIndex)
	}

	public init(pixelBuffer: inout CVPixelBuffer, colorPixelFormat: MTLPixelFormat, planeIndex: Int) throws {
		guard let texture: MTLTexture = MCCore.texture(pixelBuffer: &pixelBuffer, colorPixelFormat: colorPixelFormat, planeIndex: planeIndex) else { throw ErrorType.createError }
		self.texture = texture
	}

	public init(pixelBuffer: inout CVPixelBuffer, textureCache: CVMetalTextureCache, colorPixelFormat: MTLPixelFormat, planeIndex: Int) throws {
		guard let texture: MTLTexture = MCCore.texture(pixelBuffer: &pixelBuffer, textureCache: textureCache, colorPixelFormat: colorPixelFormat, planeIndex: planeIndex) else { throw ErrorType.createError }
		self.texture = texture
	}

	public init(texture: MTLTexture) throws {
		self.texture = texture
	}

	public func copy() throws -> MCTexture {
		guard let texture: MTLTexture = self.texture.makeTextureView(pixelFormat: self.pixelFormat) else { throw ErrorType.createError }
		return try MCTexture.init(texture: texture)
	}
}

extension MCTexture {
	public mutating func update(commandBuffer: MTLCommandBuffer, URL: URL) throws {
		guard let image: CIImage = CIImage.init(contentsOf: URL) else { throw ErrorType.createError }
		let colorSpace: CGColorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
		MCCore.ciContext.render(image, to: self.texture, commandBuffer: commandBuffer, bounds: image.extent, colorSpace: colorSpace)
	}
}

extension MCTexture {
	public mutating func getPixelBuffer() throws -> CVPixelBuffer {
		guard let pixelBuffer: CVPixelBuffer = CVPixelBuffer.create(size: CGSize.init(CGFloat(self.width), CGFloat(self.height))) else { throw ErrorType.createError }
		CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.init(rawValue: 0))
		let region = MTLRegionMake2D(0, 0, Int(self.width), Int(self.height))
		let bytesPerPixel = 4;
		let bytesPerRow = CGFloat(bytesPerPixel) * CGFloat(self.width)
		
		let tempBuffer = CVPixelBufferGetBaseAddress(pixelBuffer)
		self.texture.getBytes(tempBuffer!, bytesPerRow: Int(bytesPerRow), from: region, mipmapLevel: 0)
		CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.init(rawValue: 0))
		return pixelBuffer
	}
}

#endif
