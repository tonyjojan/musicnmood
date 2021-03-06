//
//  MusicViewController.swift
//  MusicnMood
//
//  Created by WJL on 4/13/18.
//  Copyright © 2018 Tony Jojan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Spartan

class MusicViewController:
    
UIViewController,SPTAudioStreamingDelegate,SPTAudioStreamingPlaybackDelegate{

    @IBOutlet weak var More: UIBarButtonItem!
    @IBOutlet weak var spotify: UIButton!
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var songid: String = "1qowUCis8gYY9KOMuy8fCi"
    var searchquery:String = "wrong"
    
    @IBAction func spotifylogin(_ sender: UIButton) {
//        let loginURL = SPTAuth.loginURL(forClientId: "2cf1d030727646deb8d901a1f8e7a1aa", withRedirectURL: NSURL(string: "Moosic://returnafterlogin")! as URL, scopes: [SPTAuthStreamingScope], responseType:"token")
//        UIApplication.shared.openURL(loginURL!)
        
        if UIApplication.shared.canOpenURL(loginUrl!){
            UIApplication.shared.open(loginUrl!, options: [:], completionHandler: nil)
            if auth.canHandle(auth.redirectURL) {
            }
            else{
                print("spotify login is shit")
            }
        }
    }
    
    func setup(){
        SPTAuth.defaultInstance().clientID = "2cf1d030727646deb8d901a1f8e7a1aa"
        SPTAuth.defaultInstance().redirectURL = URL(string: "Moosic://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope,SPTAuthPlaylistReadPrivateScope,SPTAuthPlaylistModifyPublicScope,SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "iphone-6-wallpaper-18.jpg")!)
        self.More.isEnabled = false
        setup()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MusicViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    
    
    @objc func updateAfterFirstLogin () {
        guard let sessionObj = UserDefaults.standard.value(forKey: "SpotifySession") as Any? else { return }
        guard let sessionDataObj = sessionObj as? Data else { return }
        let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
        self.session = firstTimeSession
        initializePlayer(authSession: session)
        Spartan.authorizationToken =  session.accessToken
        print("----------------")
        print(searchquery)
        
        _ = Spartan.search(query: searchquery, type: .track, success: { (pagingObject: PagingObject<SimplifiedTrack>) in
            // Get the tracks via pagingObject.items
           // print("1")
            print(pagingObject.items[0].id)
            self.songid = pagingObject.items[0].id as! String
        }, failure: { (error) in
            print(error)
        })
        self.spotify.isHidden  = true
        self.More.isEnabled = true
    }
        
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
       // print("logged in")
        self.player?.playSpotifyURI("spotify:track:\(songid)", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }

        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
