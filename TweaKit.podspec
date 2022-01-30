Pod::Spec.new do |spec|
  spec.name = 'TweaKit'
  spec.version = '0.0.1'
  spec.license = 'MIT'
  spec.summary = ' TweaKit, a.k.a. "Tweak It", is a pure-swift library for adjusting parameters and feature flagging.'
  spec.homepage = 'https://github.com/Cokile/TweaKit'
  spec.author = { 'Cokile': 'kelvintgx@gmail.com' }
  spec.source = { git: 'https://github.com/Cokile/TweaKit.git', tag: spec.version.to_s }

  spec.ios.deployment_target = '13.0'
  spec.swift_versions = ['5.4']

  spec.source_files = 'Sources/**/*.swift'
  spec.resource_bundle = { 'Assets': 'Sources/Resources/*.xcassets' }
end
