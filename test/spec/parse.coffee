MongoUri = require "#{LIB_ROOT}/mongo-uri"

describe "parse", ->
  it "should throw type error when missing uri portion", ->
    fn = ->
      MongoUri.parse()
    expect(fn).to.throw TypeError, /must be a string/

  it "should throw type error when not mongodb: scheme", ->
    fn = ->
      MongoUri.parse("http://test.com")
    expect(fn).to.throw TypeError, /must be mongodb scheme/

  it "should parse a simple username and password", ->
    uri = MongoUri.parse "mongodb://user:password@localhost/test"
    expect(uri.username).to.equal "user"
    expect(uri.password).to.equal "password"

  it "should parse uri encoded username and password", ->
    uri = MongoUri.parse "mongodb://%40u%2Fs%3Fe%3Ar:p%40a%2Fs%3Fs%3A@localhost"
    expect(uri.username).to.equal "@u/s?e:r"
    expect(uri.password).to.equal "p@a/s?s:"

  it "should parse a simple hostname and null port without auth", ->
    uri = MongoUri.parse "mongodb://thehostname"
    expect(uri.hosts).to.have.length 1
    expect(uri.ports).to.have.length 1
    expect(uri.hosts[0]).to.equal "thehostname"
    expect(uri.ports[0]).to.equal null

  it "should parse a set of hostnames", ->
    uri = MongoUri.parse "mongodb://host1,host2,host3:3,host4:4/path?w=1"
    expect(uri.hosts).to.have.length 4
    expect(uri.ports).to.have.length 4
    expect(uri.hosts).to.eql ["host1", "host2", "host3", "host4"]
    expect(uri.ports).to.eql [null, null, 3, 4]

  it "should parse hostnames with auth and path", ->
    uri = MongoUri.parse "mongodb://user:pass@host1:1,host2:2,host3/selected-database?w=1"
    expect(uri.hosts).to.eql ["host1", "host2", "host3"]
    expect(uri.ports).to.eql [1, 2, null]

  it "should parse null for database when unspecified", ->
    uri = MongoUri.parse "mongodb://host"
    expect(uri.database).to.equal null

  it "should parse the database when it is the last part of the uri", ->
    uri = MongoUri.parse "mongodb://user:pass@host1,host2/db"
    expect(uri.database).to.equal "db"

  it "should parse the database when there are options afterwards", ->
    uri = MongoUri.parse "mongodb://host/db?w=1&test=hi"
    expect(uri.database).to.equal "db"

  it "should specify null when database is empty string", ->
    uri = MongoUri.parse "mongodb://host/?options"
    expect(uri.database).to.equal null