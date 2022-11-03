Pod::Spec.new do |s|

s.name                  = 'ConverterUI'
s.version               = '2022.09.09'
s.license               = 'ZLIB'
s.summary               = 'MM'
s.homepage              = 'https://github.com/kornerr/MM'
s.author                = 'Michael Kapelko'
s.source                = { :git => 'https://fake.com/FAKE.git', :tag => s.version }
s.source_files          = 'src/*.swift'
s.swift_version         = '5.2'
s.ios.deployment_target = '16.0'
s.dependency 'Const'

end
