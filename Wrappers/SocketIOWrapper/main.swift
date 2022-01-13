//
//  File.swift
//  
//
//  Created by Shubham Garg on 13/01/22.
//

  
import CoreFoundation
import Dispatch
import Foundation
import SocketIO
import Starscream

let NUM_SOCKETS = 90
var socket: SocketIOClient!
var socket2: SocketIOClient!

var gotInt = false
var gotAck = false
var gotJSON = false
var gotBool = false
var gotMult = false
var gotData = false
var gotArray = false
var gotBlank = false
var gotDouble = false
var gotString = false
var gotNested = false
var gotMultAck = false
var reconnected = false
var gotBinaryAck = false

var killOnClose = true

var clientObject = NSMutableDictionary()

let manager: SocketManager

let data1 = "0".data(using: String.Encoding.utf8, allowLossyConversion: false)!
let data2 = "1".data(using: String.Encoding.utf8, allowLossyConversion: false)!
let data3 = "2".data(using: String.Encoding.utf8, allowLossyConversion: false)!
let data4 = "3".data(using: String.Encoding.utf8, allowLossyConversion: false)!
let data5 = "4".data(using: String.Encoding.utf8, allowLossyConversion: false)!
let data6 = "5".data(using: String.Encoding.utf8, allowLossyConversion: false)!
let data7 = Data()

let b64JsonString = "{\"hello\":\"+\"}"
let nspString = "/swift"

let cookieProps: [HTTPCookiePropertyKey: String] = [
    .originURL: "http://localhost",
    .path: "/",
    .name: "myCookie",
    .value: "!*'();:@&=+$,/?%#[]\" {}˚ßå"
]

let cookie = HTTPCookie(properties: cookieProps)!
let cookieArray = [cookie]
let headers = ["testing": "blah", "testing2": "b/:lah"]
var connects = 0

struct CustomData : SocketData {
    let name: String
    let age: Int

    func socketRepresentation() -> SocketData {
        return ["name": name, "age": age]
    }

}

func connectSocket() {
    socket.connect(timeoutAfter: 3) {
        print("failed to connect")
    }
}

manager = SocketManager(socketURL: URL(string:"http://localhost:8080/")!, config: [
    .reconnects(true), // default true
    .compress,
    .reconnectAttempts(-1), // default -1
    .reconnectWait(5), // default 10
    .forcePolling(false),
    .forceWebsockets(true),// default false
    .log(true),
    .forceNew(false),
    //.path("/test"),
    .extraHeaders(headers),
    .cookies([cookie]),
    //.logger(CustomLogger())
//        .connectParams([
//            "created": "2015-09-21T19:31:33+0200" as AnyObject,
//            "nonce": "W5TVkz7sxqUsY36KgekNQEVNt6LymyICgoUoTbh7ehQ=" as AnyObject,
//            "passwordDigest": "M2NmMTFjMjMyNTY3NDIwOWE1NTA4MDhiZDc2NjRmMjM5ZmViNmFlOGJiZmNjOTUwZmRkNTg3Mzg3MzI0ODkwMA==" as AnyObject,
//            "playerId": -1 as AnyObject,
//            "role": "a" as AnyObject,
//            "teamColor": "r" as AnyObject,
//            "username": "a" as AnyObject
//            ]),
])

socket = manager.defaultSocket
socket2 = manager.socket(forNamespace: "/swift")

let readQueue = DispatchQueue(label: "async read")

func readInput() {
    let input = readLine(strippingNewline: true) ?? ""

    switch input {
    case "disconnect":
        killOnClose = false
        socket.emit("disconnect")
    case "quit":
        socket.disconnect()
    case "spam":
        socket.emit("spam")
    case "connect":
        socket.connect()
    case "leaveNsp":
        manager.disconnectSocket(forNamespace: "/swift")
    case "joinNsp":
        socket2.connect()
    case "reconnect":
        manager.reconnect()
    default:
        break
    }

    readQueue.async(execute: readInput)
}

readQueue.async { readInput() }

var disconnected = false

func addHandlers(_ socket: SocketIOClient) {
    socket.on(clientEvent: .connect) {data, ack in
        guard let nsp = data[0] as? String else { fatalError("Should have namespace") }
        print("Socket connected")
        print("sending tests")
        print("In namespace: \(nsp)")
        print(socket.sid)
        socket.emit("closeTest")

        killOnClose = true

        let myJSON = [
            "name": "bob\ntracy"
        ]

        socket.emit("test")
        socket.emit("nullTest", NSNull())
        socket.emit("jsonTest", myJSON)
        socket.emit("jsonStringTest", "{\"myEvent\":\"Cute Without the \\\"E\\\" (Cut From the Team)\"}")
        socket.emit("stringTest", "lïne one\nlīne \rtwo𦅙𦅛")
        socket.emit("multData", data1, ["world": data2])
        socket.emit("arrayTest", [1, true, "test", ["test": "test"], data1, data2])
        socket.emit("jsonTest", ["data": data1, "data2": ["data3": data2], "data4": [data3]])
        socket.emit("intTest", 1)
        socket.emit("doubleTest", 2.3)
        socket.emit("boolTest", true)
        socket.emit("dataTest", data1)
        socket.emit("nested", [data1, ["test": data2, "test2": ["test3": [data3, ["test5": data4]]]], data5])
        socket.emit("multTest", [data1], 1.4, 1, "true", 2, ["test": [data2], "null": NSNull()], data3)
        socket.emit("multTest", ["test": data1], 1.4, 1, "true", true, ["test": [data2]], data3)
        socket.emit("base64JSONTest", b64JsonString)
    //        socket.emit("customObj", CustomData(name: "Erik", age: 24))
    }

    socket.on(clientEvent: .connect) {data, ack in
        guard let nsp = data[0] as? String else { fatalError("Should have namespace") }

        print("Socket connected")
        print("sending tests")
        print("In namespace: \(nsp)")
        print(socket.sid)
        socket.emit("closeTest")
    }

    socket.once("deinit") {data, ack in
    //    print("closing socket")
    //     socket.disconnect()
    }

    socket.on(clientEvent: .disconnect) {data, ack in
        guard killOnClose else { return }

        if let reason = data[0] as? String {
            print("Socket disconnected: \(reason)")
            exit(1)
        }
    }

    socket.on("error") {data, ack in
        if let err = data[0] as? String {
            print("Got error: \(err)")
        }
    }

    socket.on("reconnect") {data, ack in
        print("Socket reconnecting: \(data[0])")
    }

    socket.on("reconnectAttempt") {data, ack in
        if let triesLeft = data[0] as? Int {
            print("Reconnect tries left: \(triesLeft)")
            // exit(1)t
        }
    }

    socket.on("someSpam") {data, ack in
        ack.with(true, false)
        print("Got some spam \(data[0] as! Int)")
    }

    socket.on("closeTest") {data, ack in
        print("got closeTest")
        // socket.close()
    }

    socket.on("nullTest") {data, ack in
        print("Got null test")
    }

    socket.on("blankTest") {data, ack in
        print("got blank test")
        assert(data.count == 0, "Failed blank test: \(data)")
        gotBlank = true
    }

    socket.on("nestedTest") {data, ack in
        print("Got nested test")
        // println(data)
        gotNested = true
    }

    socket.on("multipleItems") {data, ack in
        print("Got multipleItems")
        gotMult = true
        print(data)
    }

    socket.on("foobar") {data, ack in
        if let json = data[0] as? NSDictionary {
            print(json["test"]!) // foo bar
        }
    }

    socket.on("boolTest") {data, ack in
        if let bool = data[0] as? Bool {
            print("got bool test")
            assert(bool == true, "Failed boolTest") // true
            gotBool = true
        }
    }

    socket.on("jsonTest") {data, ack in
        print("got json test")
        if let json = data[0] as? NSDictionary {
            if let str = json["foo"] as? String {
                assert(str == "string\ntest test", "Failed json test")
                gotJSON = true
            }
        } else {
            assert(false, "Failed json test")
        }
    }

    socket.on("stringTest") {data, ack in
        print("got string test")
        if let str = data[0] as? String {
            assert(str == "lïne one\nlīne \rtwo", "Failed string test \(str)")
            gotString = true
        } else {
            assert(false, "failed string test")
        }
    }

    socket.on("arrayTest") {data, ack in
        if let array = data[0] as? NSArray {
            print("Got array test")
            assert(array[0] as! Int == 2, "Failed arrayTest") // 2
            assert(array[1] as! String == "test", "Failed arrayTest") // "test"
            gotArray = true
        }
    }

    socket.on("intTest") {data, ack in
        if let intData = data[0] as? Int {
            print("got int test")
            assert(intData == 2, "Failed intTest")
            gotInt = true
        }
    }

    socket.on("doubleTest") {data, ack in
        print("got double test")
        if let d = data[0] as? Double {
            assert(d == 2.2, "Failed doubleTest")
            gotDouble = true
        } else {
            assert(false, "Failed doubleTest")
        }
    }

    socket.on("dataTest") {data, ack in
        if let _ = data[0] as? Data {
            print("Got binary")
            gotData = true
        }
    }

    socket.on("objectDataTest") {data, ack in
        if let dict = data[0] as? [String: Any] {
            if let data = dict["data"] as? Data {
                let string = String(data: data, encoding: .utf8)
                print("Got data: \(string!)")
            }
        }
    }

    socket.on("mult") {data, ack in
        print("got mult")
    }

    socket.on("burstTest") {data, ack in
        print("got burst")
    }

    socket.on("ackEvent") {data, ack in
        print("Got ackEvent")
        // println(data)
        if let str = data[0] as? String {
            assert(str == "gakgakgak", "Failed ackEvent")
            gotAck = true
        }

        ack.with("got it", data)

        socket.emitWithAck("ackack", ["test"]).timingOut(after: 1) {ackData in
            print("got ackack!!")
            if let _ = ackData[0] as? NSDictionary {
                // println(dict)
            } else {
                if let str = ackData[0] as? String {
                    if str == "No ACK" {
                        print("The server did not ack")
                    } else {
                        print(str)
                    }
                } else {
                    assert(ackData.count != 0, "emitWithAck failed")
                }
            }
        }

        socket.emitWithAck("binaryEmitAck", "test", 1, data1).timingOut(after: 0) {ackData in
            print("got ackack2")

            assert(ackData.count == 2, "\(ackData)")
        }

    }

    socket.on("binaryAckEvent") {data, ack in
        print("Got binaryAckEvent")
        if let data = data[0] as? Data {
            let str = String(data: data, encoding: .utf8)!
            assert(str == "gakgakgak2", "Binary in binaryAckEvent is wrong")
            gotBinaryAck = true
            ack.with(data, "Got your binary ack", ["Hello": "hello"])
        } else {
            assert(false, "binaryAckEvent failed with data: \(data)")
        }
    }

    socket.on("multAckEvent") {data, ack in
        assert(data.count != 0, "data in multAckEvent is empty")
        print("got multiAckEvent")

        if let gakData = data[0] as? Data {
            print("Got gakData in multAckEvent")
            let str = String(data: gakData, encoding: .utf8)!
            // println(gakData)
            // println(str)
            assert(str == "gakgakgak3", "Binary in multAckEvent is wrong")

            if let num = data[1] as? Int {
                print("Got num in multAckEvent")
                assert(num == 2, "Num != 2 in multAckEvent")
            } else {
                assert(false, "multAckEvent int != 2")
            }
        } else {
            assert(false, "multAckEvent data failure")
        }

        gotMultAck = true
        ack.with("Got your multiack dude", 2.2)
    }

    socket.on("nspTest") {data, ack in
        print("got nsptest")
        print(data)
    }

    socket.on("nspTestMult") {data, ack in
        print("got nspTestMult")
        print(data)
    }

    socket.on("nspMult") {data, ack in
        print("got nspmult")
        print(data)
    }

    socket.on("echo") {data, ack in
        print("got echo")
    }

    socket.on("nspLeave") {data, ack in
        socket.leaveNamespace()
    }

    socket.on("unicodeTest") {data, ack in
        print("got unicode test")

        if let str = data[0] as? String {
            assert(str == "lïne one\nlīne \rtwo𦅙𦅛", "Failed unicodeTest")
            return
        }

        assert(false, "Failed unicodeTest")
    }

    socket.on("reconnectTest") {data, ack in
        print("trying reconnect")

        if !reconnected {
            manager.reconnect()
            reconnected = true
        }
    }

    socket.on("currentAmount") {data, ack in
        if let cur = data[0] as? Double {
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                socket.emit("update", ["amount": cur + 2.50])
            }

            let a = "dude"
            ack.with("Got your currentAmount", a)
        }
    }

    socket.on("cyrllicTest") {data, ack in
        print("got cyrllicTest")
    }

    socket.on("testAck") {data, ack in
    //    print("testAck\(data[0] as! Int)")
        ack.with("hello \(data[0] as! Int)")
    }

    socket.on("kick") {data, ack in
        print("got kicked")
    }
}

addHandlers(socket)
addHandlers(socket2)

connectSocket()

DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6)) {
//    print("socket closing")
//
//    assert(connects == NUM_SOCKETS, "Did not connect all sockets: \(connects)")
//    assert(gotBinaryAck, "Failed binary ack test")
//    assert(gotArray, "Failed array test")
//    assert(gotAck, "Failed ack test")
//    assert(gotBlank, "Failed blank test")
//    assert(gotData, "Failed data test")
//    assert(gotDouble, "Failed double test")
//    assert(gotInt, "Failed int test")
//    assert(gotNested, "Failed nested test")
//    assert(gotMult, "Failed multiple test")
//    assert(gotMultAck, "Failed multack test")
//    assert(gotString, "Failed string test")
}

CFRunLoopRun()
