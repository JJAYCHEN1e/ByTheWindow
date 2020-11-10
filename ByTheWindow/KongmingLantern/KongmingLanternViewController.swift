//
//  KongmingLanternViewController.swift
//  ByTheWindow
//
//  Created by 陈俊杰 on 11/10/20.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import UIKit
import PencilKit

class KongmingLanternViewController: UIViewController {
    var drawingBackgroundImageView: UIImageView?
    var lanternImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let drawingBackgroundImageView = UIImageView(image: UIImage(named: "KongmingLantern_Drawing_Background")!)
        self.drawingBackgroundImageView = drawingBackgroundImageView
        drawingBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(drawingBackgroundImageView)
        
        NSLayoutConstraint.activate([
            drawingBackgroundImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            drawingBackgroundImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            drawingBackgroundImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            drawingBackgroundImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        let lanternImage = UIImage(named: "KongmingLantern_Drawing_Lantern")!
        let lanternImageView = UIImageView(image: lanternImage)
        self.lanternImageView = lanternImageView
        lanternImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(lanternImageView)
        
        NSLayoutConstraint.activate([
            lanternImageView.widthAnchor.constraint(equalTo: lanternImageView.heightAnchor, multiplier: lanternImage.size.width / lanternImage.size.height),
            lanternImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.8),
            lanternImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            lanternImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        let drawingPKCanvasView = PKCanvasView()
        drawingPKCanvasView.backgroundColor = .clear
        drawingPKCanvasView.isOpaque = false
        drawingPKCanvasView.translatesAutoresizingMaskIntoConstraints = false
        drawingPKCanvasView.showsVerticalScrollIndicator = false
        drawingPKCanvasView.showsHorizontalScrollIndicator = false
        drawingPKCanvasView.tool = PKInkingTool(.pen, color: .black, width: 30)
        self.view.addSubview(drawingPKCanvasView)
        
        NSLayoutConstraint.activate([
            drawingPKCanvasView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            drawingPKCanvasView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            drawingPKCanvasView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            drawingPKCanvasView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        if let window = UIApplication.shared.windows.first, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: drawingPKCanvasView)
            toolPicker.addObserver(drawingPKCanvasView)
            drawingPKCanvasView.becomeFirstResponder()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    @objc func doubleTapped() {
        let progress_one = UIImageView(image: UIImage(named: "KongmingLantern_Progress_1")!)
        progress_one.alpha = 0
        progress_one.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progress_one)
        NSLayoutConstraint.activate([
            progress_one.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            progress_one.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            progress_one.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            progress_one.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        UIView.transition(with: progress_one, duration: 2, options: .curveEaseInOut, animations: {
            progress_one.alpha = 1
        }, completion: { completed in
            if completed {
                let progress_two = UIImageView(image: UIImage(named: "KongmingLantern_Progress_2")!)
                progress_two.alpha = 0
                progress_two.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(progress_two)
                NSLayoutConstraint.activate([
                    progress_two.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                    progress_two.heightAnchor.constraint(equalTo: self.view.heightAnchor),
                    progress_two.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    progress_two.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                ])
                
                UIView.transition(with: progress_two, duration: 2, options: .curveEaseInOut, animations: {
                    progress_two.alpha = 1
                }, completion: { completed in
                    if completed {
                        let progress_three = UIImageView(image: UIImage(named: "KongmingLantern_Progress_3")!)
                        progress_three.alpha = 0
                        progress_three.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addSubview(progress_three)
                        NSLayoutConstraint.activate([
                            progress_three.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                            progress_three.heightAnchor.constraint(equalTo: self.view.heightAnchor),
                            progress_three.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                            progress_three.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                        ])
                        
                        UIView.transition(with: progress_two, duration: 2, options: .curveEaseInOut, animations: {
                            progress_three.alpha = 1
                        }, completion: nil)
                    }
                }
                )
            }
        }
        )
    }
}
