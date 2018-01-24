//
//  ViewController.swift
//  Analyzer
//
//  Created by Benjamin Dietzkis on 2018/01/24.
//  Copyright © 2018 Benjamin Dietzkis. All rights reserved.
//

import UIKit

class ViewController : UIViewController {
    override func loadView() {
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 500, height: 35))
        label.text = "Color Analyzer"
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .white

        let view = UIView()
        view.backgroundColor = .black
        self.view = view
        view.addSubview(label)

        let imageView = UIImageView(frame: CGRect(x: 20, y: 85, width: 150, height: 100))
        imageView.image = UIImage(named: "havaii.png")
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)

        let domView = UIView(frame: CGRect(x: 20, y: imageView.frame.origin.y+imageView.frame.size.height+10, width: 100, height: 100))
        domView.backgroundColor = imageView.image?.backgroundColor
        view.addSubview(domView)
        domView.layer.cornerRadius = 4
        domView.layer.borderColor = UIColor.darkGray.cgColor
        domView.layer.borderWidth = 1

        let domLabel = UILabel(frame: CGRect(x: domView.frame.origin.x+domView.frame.size.width+20, y: domView.frame.origin.y+domView.frame.size.height-35, width: 500, height: 35))
        domLabel.text = "Background (Most Dominant)"
        domLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        domLabel.textColor = .white
        view.addSubview(domLabel)

        let priView = UIView(frame: CGRect(x: 20, y: domView.frame.origin.y+domView.frame.size.height+10, width: 100, height: 100))
        priView.backgroundColor = imageView.image?.primaryColor
        view.addSubview(priView)
        priView.layer.cornerRadius = 4
        priView.layer.borderColor = UIColor.darkGray.cgColor
        priView.layer.borderWidth = 1

        let priLabel = UILabel(frame: CGRect(x: priView.frame.origin.x+priView.frame.size.width+20, y: priView.frame.origin.y+priView.frame.size.height-35, width: 500, height: 35))
        priLabel.text = "Primary"
        priLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        priLabel.textColor = .white
        view.addSubview(priLabel)

        let secView = UIView(frame: CGRect(x: 20, y: priView.frame.origin.y+priView.frame.size.height+10, width: 100, height: 100))
        secView.backgroundColor = imageView.image?.secondaryColor
        view.addSubview(secView)
        secView.layer.cornerRadius = 4
        secView.layer.borderColor = UIColor.darkGray.cgColor
        secView.layer.borderWidth = 1

        let secLabel = UILabel(frame: CGRect(x: secView.frame.origin.x+secView.frame.size.width+20, y: secView.frame.origin.y+secView.frame.size.height-35, width: 500, height: 35))
        secLabel.text = "Secondary (Dom ÷ Pri)"
        secLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        secLabel.textColor = .white
        view.addSubview(secLabel)

        let detView = UIView(frame: CGRect(x: 20, y: secView.frame.origin.y+secView.frame.size.height+10, width: 100, height: 100))
        detView.backgroundColor = imageView.image?.detailColor
        view.addSubview(detView)
        detView.layer.cornerRadius = 4
        detView.layer.borderColor = UIColor.darkGray.cgColor
        detView.layer.borderWidth = 1

        let detLabel = UILabel(frame: CGRect(x: detView.frame.origin.x+detView.frame.size.width+20, y: detView.frame.origin.y+detView.frame.size.height-35, width: 500, height: 35))
        detLabel.text = "Detail (Most Contrasting)"
        detLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        detLabel.textColor = .white
        view.addSubview(detLabel)
    }
}

