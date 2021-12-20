// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeLayer

/// The CALayer type responsible for rendering `ShapeLayerModel`s
final class ShapeLayer: CALayer {

  // MARK: Lifecycle

  init(shapeLayer: ShapeLayerModel) {
    self.shapeLayer = shapeLayer
    super.init()

    for item in shapeLayer.items {
      // TODO: Can items other than `Group`s appear at the top level?
      // If so, how does that work?
      if let group = item as? Group {
        let sublayer = ShapeItemLayer(items: group.items)
        addSublayer(sublayer)
      }
    }
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let layer = layer as? Self else {
      fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
    }

    shapeLayer = layer.shapeLayer
    super.init(layer: layer)
  }

  // MARK: Internal

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in sublayers ?? [] {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  private let shapeLayer: ShapeLayerModel

}

// MARK: AnimationLayer

extension ShapeLayer: AnimationLayer {
  func setupAnimations(context: LayerAnimationContext) {
    addBaseAnimations(for: shapeLayer, context: context)

    for sublayer in (sublayers ?? []) {
      if let animationLayer = sublayer as? AnimationLayer {
        animationLayer.setupAnimations(context: context)
      }
    }
  }
}

// MARK: - ShapeLayerModel + LayerConstructing

extension ShapeLayerModel: LayerConstructing {
  func makeLayer(context: LayerContext) -> AnimationLayer {
    ShapeLayer(shapeLayer: self)
  }
}
