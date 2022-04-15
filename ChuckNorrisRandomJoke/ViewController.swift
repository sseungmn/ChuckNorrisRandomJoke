//
//  ViewController.swift
//  ChuckNorrisRandomJoke
//
//  Created by seungminOH on 2022/04/15.
//

import UIKit

class ViewController: UIViewController {

    let jokeDisplayLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .italicSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()

        JokeAPIProvider().fetchRandomJoke { response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async {
                    print(data)
                    self.jokeDisplayLabel.text = data.joke
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func makeUI() {
        let padding: CGFloat = 20
        let labelHeight: CGFloat = 300

        view.backgroundColor = .black

        view.addSubview(jokeDisplayLabel)
        jokeDisplayLabel.frame = CGRect(
            origin: CGPoint(
                x: padding,
                y: (view.frame.height - labelHeight) / 2
            ),
            size: CGSize(
                width: view.frame.width - 2 * padding,
                height: labelHeight
            )
        )
    }
}
