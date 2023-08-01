//
//  ViewController.swift
//  ActivityControllerDemo
//
//  Created by Anup D'Souza on 14/06/23.
//

import UIKit
import LinkPresentation

class ViewController: UIViewController {
    
    typealias CompletionWithItemsHandler = (UIActivity.ActivityType?, Bool, [Any]?, Error?) -> Void
    var metadata: LPLinkMetadata?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func shareText() {
        shareItems(items: ["Hello World !"])
    }

    @IBAction func shareLink() {
        guard let url = URL(string: "https://simple.wikipedia.org/wiki/Koala") else {
            return
        }
        shareItems(items: [url])
    }
    
    @IBAction func shareImages() {
        guard let toucan = UIImage(named: "toucan"), let koala = UIImage(named: "koala") else {
            return
        }
        shareItems(items: [toucan, koala])
    }

    @IBAction func shareItems() {
        guard let url = URL(string: "https://simple.wikipedia.org/wiki/Koala"), let koala = UIImage(named: "koala") else {
            return
        }
        setupShareMetadataWithUrls([url])
        shareItems(items: [url, koala, "Hello Universe!", self]) { _, success, _, error in
            print("share \(success ? "successful" :  "failed: \(String(describing: error?.localizedDescription))")")
        }
    }

    @IBAction func shareLinkWithIconPreview() {
        let url = URL(string: "https://simple.wikipedia.org/wiki/Koala")!
        LPMetadataProvider().startFetchingMetadata(for: url) { linkMetadata, _ in
            linkMetadata?.iconProvider = linkMetadata?.imageProvider
            self.metadata = linkMetadata
            DispatchQueue.main.async {
                self.shareItems(items: [self])
            }
        }
    }
    
    @IBAction func shareLinkWithCustomIconPreview() {
        let url = URL(string: "https://simple.wikipedia.org/wiki/Koala")!
        LPMetadataProvider().startFetchingMetadata(for: url) { linkMetadata, _ in
            DispatchQueue.main.async {
                let imageURLString = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Koala02.jpeg/2560px-Koala02.jpeg"
                LPMetadataProvider().startFetchingMetadata(for: URL(string: imageURLString)!) { imageMetadata, _ in
                    linkMetadata?.imageProvider = imageMetadata?.imageProvider
                    linkMetadata?.iconProvider = imageMetadata?.imageProvider
                    self.metadata = linkMetadata
                    DispatchQueue.main.async {
                        self.shareItems(items: [self])
                    }
                }
            }
        }
    }
    
    @IBAction func setupMetadata() {
        let linkMetadata = LPLinkMetadata()
        linkMetadata.title = "Look what I've shared !"
        if let appIconImage = UIImage(named: "AppIcon") {
            let iconProvider = NSItemProvider(object: appIconImage)
            linkMetadata.iconProvider = iconProvider
        }
        metadata = linkMetadata
    }
    
    @IBAction func clearMetadata() {
        metadata = nil
    }

    private func shareItems(items: [Any], _ onCompletion: CompletionWithItemsHandler? = nil) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: [])
        activityViewController.completionWithItemsHandler = onCompletion
        present(activityViewController, animated: true)
    }
    
    private func setupShareMetadataWithUrls(_ urls: [URL]) {
        let linkMetadata = LPLinkMetadata()
        linkMetadata.title = "Look what I've shared !"
        linkMetadata.url = urls.first
        if let appIconImage = UIImage(named: "AppIcon") {
            let iconProvider = NSItemProvider(object: appIconImage)
            linkMetadata.iconProvider = iconProvider
        }
        metadata = linkMetadata
    }
}

extension ViewController: UIActivityItemSource {

    public func activityViewControllerPlaceholderItem(_ controller: UIActivityViewController) -> Any {
        metadata?.title ?? ""
    }

    public func activityViewController(_ controller: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        metadata?.url
    }

    public func activityViewControllerLinkMetadata(_ controller: UIActivityViewController) -> LPLinkMetadata? {
        metadata
    }
}
