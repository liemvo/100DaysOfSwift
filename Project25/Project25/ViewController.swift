//
//  ViewController.swift
//  Project25
//
//  Created by Liem Vo on 11/4/19.
//  Copyright © 2019 Liem Vo. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
	
	private var images = [UIImage]()
	
	private var peerID  = MCPeerID(displayName: UIDevice.current.name)
	private var mcSession: MCSession?
	private var mcAdvertiserAssistant: MCAdvertiserAssistant?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Selfie Share"
		let connectButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
		let peersButton = UIBarButtonItem(title: "Peers", style: .plain, target: self, action: #selector(showPeers))
		
		navigationItem.leftBarButtonItems = [connectButton, peersButton]
		
		let photoButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
		let messageButton = UIBarButtonItem(title: "Text", style: .plain, target: self, action: #selector(sendText))
		navigationItem.rightBarButtonItems = [photoButton, messageButton]
		
		mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
		mcSession?.delegate = self
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
		if let imageView = cell.viewWithTag(1000) as? UIImageView {
			imageView.image = images[indexPath.item]
		}
		
		return cell
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image  = info[.editedImage] as? UIImage else { return }
		dismiss(animated: true)
		images.insert(image, at: 0)
		collectionView.reloadData()
	
		if  let imageData = image.pngData() {
			self.sendData(data: imageData)
		}
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		
	}
	
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		dismiss(animated: true)
	}
	
	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		dismiss(animated: true)
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		switch state {
		case .connected:
			print("Connected: \(peerID.displayName)")
		case .connecting:
			print("Connecting: \(peerID.displayName)")
		case .notConnected:
			print("Not Connected: \(peerID.displayName)")
			DispatchQueue.main.async { [weak self] in
				let ac = UIAlertController(title: "Disconnected", message: "Not Connected: \(peerID.displayName)", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
				self?.present(ac, animated: true)
			}
		@unknown default:
			print("Unknow state received: \(peerID.displayName)")
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		DispatchQueue.main.async { [weak self] in
			if let image = UIImage(data: data) {
				self?.images.insert(image, at: 0)
				self?.collectionView.reloadData()
			} else if String(decoding: data, as: UTF8.self) != nil {
				let ac = UIAlertController(title: "Receive Text", message: String(decoding: data, as: UTF8.self), preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "OK", style: .cancel))
				self?.present(ac, animated: true)
			}
		}
	}
	
	@objc private func importPicture() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}
	
	@objc private func showConnectionPrompt() {
		let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
		ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(ac, animated: true)
	}
	
	@objc private func sendText() {
		let ac = UIAlertController(title: "Send a message", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
			guard let message = ac?.textFields?[0].text else { return }
			
			let textData = Data(message.utf8)
			self?.sendData(data: textData)
		})
		
		present(ac, animated: true)
	}
	
	@objc private func showPeers() {
		
		guard let mcSession  = mcSession else { return }
		
		let ac = UIAlertController(title: "Peers", message: nil, preferredStyle: .actionSheet)
		
		for i in 0 ..< mcSession.connectedPeers.count {
			let id = mcSession.connectedPeers[i]
			ac.addAction(UIAlertAction(title: id.displayName, style: .default))
		}
		
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		present(ac, animated: true)
	}
	
	private func sendData(data: Data) {
		guard let mcSession  = mcSession else { return }
		if mcSession.connectedPeers.count > 0 {
			do {
				try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
			} catch {
				let errorAc   = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
				errorAc.addAction(UIAlertAction(title: "OK", style: .default))
				present(errorAc, animated: true)
			}
		}
	}

	private func startHosting(action: UIAlertAction) {
		guard let mcSession = mcSession else { return }
		mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
		mcAdvertiserAssistant?.start()
	}
	
	private func joinSession(action: UIAlertAction) {
		guard let mcSession = mcSession else { return }
		let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
		mcBrowser.delegate = self
		present(mcBrowser, animated: true)
	}
	
}
