//
//  AudioManager.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//  Referenced: https://medium.com/@samwise23/playing-audio-with-avplayer-in-swift-b3ce82fbeb6d
//

import AVFoundation
import Combine
import Foundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var player: AVPlayer?
    private var url: URL?
    private var session = AVAudioSession.sharedInstance()
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var elapsed: Double = 0
    private var cancellable: Cancellable?
    
    @Published var elapsedTime: String = ""
    @Published var elapsedTimeDouble: Double = 0
    @Published var timeLeft: String = ""
    @Published var isTrackFinished: Bool = false
    var onSongFinished: (() -> Void)?
    
    private init() {
        elapsedTime = calculatedElapsedTime
        timeLeft = calculatedTimeLeft
    }
    
    private func activateSession() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth]
            )
        } catch {
            dump(error)
        }
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            dump(error)
        }
        
        do {
            try session.overrideOutputAudioPort(.speaker)
        } catch {
            dump(error)
        }
    }
    
    private func setupTimer() {
        cancellable = timer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                guard let playbackDuration else { return }
                self.elapsed += 1
                
                if elapsed >= playbackDuration {
                    self.cancellable?.cancel()
                    self.clearElapsedTime()
                    self.setCalculatedTime()
                    self.onSongFinished?()
                } else {
                    self.setCalculatedTime()
                    self.elapsedTimeDouble = elapsed / playbackDuration
                }
            }
    }
    
    private func setupPlayer() {
        guard let url else { return }
        activateSession()
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        if let player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }
    }
    
    private func setCalculatedTime() {
        self.elapsedTime = self.calculatedElapsedTime
        self.timeLeft = self.calculatedTimeLeft
    }
    
    private func clearElapsedTime() {
        self.elapsed = 0
        self.elapsedTimeDouble = 0
    }
    
    func startAudio(url: URL) {
        self.url = url
        self.setupPlayer()
        
        if let player {
            player.play()
            clearElapsedTime()
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            setupTimer()
        }
    }
    
    func deactivateSession() {
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error as NSError {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    func play() {
        if elapsed == 0 { setupPlayer() }
        if let player {
            player.play()
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            setupTimer()
        }
    }
    
    func pause() {
        if let player {
            player.pause()
            cancellable?.cancel()
        }
    }
    
    private var playbackDuration: Double? {
        guard let player else {
            return nil
        }
        
        if player.currentItem?.duration == .invalid || 
           player.currentItem?.duration == .indefinite {
            return nil
        }
        
        return player.currentItem?.duration.seconds ?? 0
    }
    
    private var calculatedElapsedTime: String {
        guard playbackDuration != nil else { return "-:--" }
        let seconds = modf(elapsed).0
        let milliseconds = modf(elapsed).1
        let duration = Duration.seconds(seconds) + Duration.milliseconds(milliseconds)
        return duration.formatted(.time(pattern: .minuteSecond))
    }
    
    private var calculatedTimeLeft: String {
        guard let playbackDuration else { return "-:--" }
        let left = playbackDuration - elapsed
        let seconds = modf(left).0
        let milliseconds = modf(left).1
        let duration = Duration.seconds(seconds) + Duration.milliseconds(milliseconds)
        let timeLeft = duration.formatted(.time(pattern: .minuteSecond))
        return "-" + timeLeft
    }
}
