//
//  AudioManager.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//  Referenced: https://medium.com/@samwise23/playing-audio-with-avplayer-in-swift-b3ce82fbeb6d
//

import AVFoundation
import Foundation

final class AudioManager {
    static let shared = AudioManager()
    
    private var player: AVPlayer?
    
    private var session = AVAudioSession.sharedInstance()
    
    private init() {}
    
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
    
    func startAudio(url: URL) {
        activateSession()
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        if let player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }
        
        if let player {
            player.play()
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
        if let player {
            player.play()
        }
    }
    
    func pause() {
        if let player {
            player.pause()
        }
    }
    
    var playbackDuration: Double {
        guard let player else {
            return 0
        }
        
        return player.currentItem?.duration.seconds ?? 0
    }
}
