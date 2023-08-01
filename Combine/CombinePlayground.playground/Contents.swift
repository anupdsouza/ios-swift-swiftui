import Foundation
import Combine
enum WeatherError: Error {
    case unpredictableWeather
}
let weatherPublisher = PassthroughSubject<Int, WeatherError>()

let subscriber = weatherPublisher
    .filter { $0 > 25 }
    .sink(receiveCompletion: { _ in
        print("process complete")
    }, receiveValue: { value in
        print("A summer day of \(value) °C")
    })

let newSubscriber = weatherPublisher.handleEvents(receiveSubscription: { subscription in
    print("New subscription \(subscription)")
}, receiveOutput: { output in
    print("New output value \(output)")
}, receiveCompletion: { error in
    print("Subscription completed with error \(error)")
}, receiveCancel: {
    print("Subscription cancelled")
}, receiveRequest: { demand in
    print("Subscription received request \(demand)")
}).sink { error in
    print("Completed with error \(error)")
} receiveValue: { value in
    print("Subscription received value \(value)")
}


weatherPublisher.send(25)
weatherPublisher.send(20)
weatherPublisher.send(28)
weatherPublisher.send(completion: .failure(.unpredictableWeather))
weatherPublisher.send(30)
