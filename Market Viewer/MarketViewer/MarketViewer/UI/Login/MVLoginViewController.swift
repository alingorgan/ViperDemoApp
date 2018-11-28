//
//  MVLoginViewController.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import UIKit

protocol MVLoginView: MVView {
    
    var viewModel: MVLoginViewModel? { get set }
}

final class MVLoginViewController: UIViewController, MVLoginView {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var presenter: MVLoginViewPresenting!
    
    var viewModel: MVLoginViewModel? = nil {
        didSet {
            updateView(with: viewModel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = title
        
        presenter.viewIsReady()
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        guard let username = userNameTextField.text,
            let password = passwordTextField.text
        else { return }
        
        presenter.handleLoginAction(with: username, and: password)
    }
    
    private func updateView(with viewModel: MVLoginViewModel?) {
        titleLabel.text = viewModel?.title
        userNameTextField.text = viewModel?.userName
        passwordTextField.text = viewModel?.password
        loginButton.setTitle(viewModel?.loginButtonTitle, for: .normal)
    }
}
