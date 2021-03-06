//
//  Message.swift
//  ListIt
//
//  Created by Jonathan Green on 1/7/16.
//  Copyright © 2016 Jonathan Green. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SwiftEventBus
import ImagePickerSheetController
import Photos


var blueColor = UIColor(red: 0.596, green: 0.749, blue: 0.804, alpha: 1)

class MessageViewController: JSQMessagesViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var presenter = getData()
    
    var cloudFunctions = TheCloud()
    
    var avatar:JSQMessagesAvatarImage!
    var outgoingBubbleImageData = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.grayColor())
    var incomingBubbleImageData = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(blueColor)
    
    
    var messages:[JSQMessage] = [JSQMessage]()
    
    var userIcon:UIImage!
    var sellerId:String!
    var selectedImage:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SwiftEventBus.onMainThread(self, name: "NewMessage") { (result) -> Void in
            
            self.newMessages()
        }
       
        presenter.addChannel("test")
       
        
        /*var avatar:JSQMessagesAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("JG", backgroundColor: blueColor, textColor: UIColor.lightTextColor(), font: UIFont.systemFontOfSize(14.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))*/
    
        
        
        
        setup()
        addMessages()
            
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.collectionView?.reloadData()

        });

        
    }
    
    // func that fires when assecory button is clicked
    func getImage() {
        
        let manager = PHImageManager.defaultManager()
        let initialRequestOptions = PHImageRequestOptions()
        initialRequestOptions.resizeMode = .Fast
        initialRequestOptions.deliveryMode = .HighQualityFormat
        
        let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            var sourceType = source
            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                sourceType = .PhotoLibrary
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .Image)
        controller.maximumSelection = 1
        
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo", comment: "Action Title"), secondaryTitle: NSLocalizedString("Use This Image", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.Camera)
            }, secondaryHandler: { action, numberOfPhotos in
                print("Comment \(numberOfPhotos) photos")
                
                let size = CGSize(width: controller.selectedImageAssets[0].pixelWidth, height: controller.selectedImageAssets[0].pixelHeight)
                
                manager.requestImageForAsset(controller.selectedImageAssets[0],
                    targetSize: size,
                    contentMode: .AspectFill,
                    options:initialRequestOptions) { (finalResult, _) in
                        
                        self.selectedImage = finalResult
                        print(finalResult)
                        
                        let photo = JSQPhotoMediaItem(image:finalResult)
                        
                        let messageMedia = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: photo)
                        
                        self.presenter.sendMessage(messageMedia, sellerId: "test",hasImage:true,image:finalResult!) { () -> Void in
                            
                            self.messages += [messageMedia]
                            self.finishSendingMessage()
                            self.cloudFunctions.pushMessage("test")
                            
                        }
                        
                        
                       
                }
                
                
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
            print("Cancelled")
        }))
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            controller.modalPresentationStyle = .Popover
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
       
        dismissViewControllerAnimated(true, completion: nil)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


//MARK - Setup
extension MessageViewController {
    func addMessages() {
        
            presenter.getMessages("test") { (item) -> Void in
                
                
                for message in item {
                    
                    print("messages from parse \(message.media)")
                    
                }
                
                self.messages = item
                self.reloadMessagesView()                
            }
    }
    
    func newMessages(){
        
        presenter.getMessages("test") { (item) -> Void in
            
            for var i = 0; i < item.count; i++ {
                
                if i > self.messages.count {
                    
                    print("new item", i)
                    print("old item", self.messages.count)
                    
                    self.messages.append(item[i])
                }
            }
            
            //self.finishSendingMessage()
            self.reloadMessagesView()
            
        }
    }
    
    func setup() {
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString

    }
}

//MARK - Data Source
extension MessageViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubbleImageData
        default:
            return self.incomingBubbleImageData
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let diameter = UInt(kJSQMessagesCollectionViewAvatarSizeDefault)
        let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(userIcon, diameter: diameter)
        
        let avatarImage2 = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "placeholder"), diameter: diameter)
        
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return avatarImage
        default:
            return avatarImage2
        }
        
    }
    
}



//MARK - Toolbar
extension MessageViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
            
            let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
            presenter.sendMessage(message, sellerId: "test",hasImage:false,image:UIImage(named: "placeholder")!) { () -> Void in
            
            self.messages += [message]
            self.finishSendingMessage()
            print("pressed send")
            self.cloudFunctions.pushMessage("test")
            
        }
       
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        print("didPressAccessoryButton")
        
        getImage()
    }
}