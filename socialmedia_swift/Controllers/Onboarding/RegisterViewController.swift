//
//  RegisterViewController.swift
//  socialmedia_swift
//
//  Created by may on 2/6/23.
//

import UIKit
import Combine

class RegisterViewController: UIViewController {
	
	private var viewModel = AuthViewViewModel()
	private var subscriptions: Set<AnyCancellable> = []
	
	private let registerLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 30, weight: .heavy)
		label.textColor = .label
		label.text = "Create your account"
		
		return label
	}()
	
	private let emailTextfield: CustomTextField = {
		let field = CustomTextField(placeholder: "Email", keyboardType: .emailAddress)
		return field
	}()
	
	private let passwordTextfield: CustomTextField = {
		let field = CustomTextField(placeholder: "Password")
		field.isSecureTextEntry = true
		
		return field
	}()
	
	private lazy var signUpBtn: CustomOvalButton = {
		let btn = CustomOvalButton(title: "Create account")
		btn.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
		
		return btn
	}()
	
	@objc func didTapSignUp(){
		viewModel.createUser()
	}
	
	private func bindViews(){
		emailTextfield.addTarget(self, action: #selector(didChangeEmailField), for: .editingChanged)
		passwordTextfield.addTarget(self, action: #selector(didChangePasswordField), for: .editingChanged)
		
		// when $isAuthenticationValid changes
		// $ gets publisher itself
		// enables the create account btn
		viewModel.$isAuthenticationValid.sink { [weak self] isValid in
			self?.signUpBtn.isEnabled = isValid
		}
		.store(in: &subscriptions)
		
		// when $user changes
		// dismiss onboarding vc when account is created
		viewModel.$user.sink { [weak self] user in
			guard user != nil else {return}
			guard let vc = self?.navigationController?.viewControllers.first as? OnboardingViewController else {return}
			vc.dismiss(animated: true)
		}
		.store(in: &subscriptions)
		
		// when $error changes
		viewModel.$error.sink { [weak self] error in
			guard let error = error?.localizedDescription else {return}
			self?.presentAlert(with: error)
		}
		.store(in: &subscriptions)
	}
	
	private func presentAlert(with error: String){
		let ac = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
		let dismissBtn = UIAlertAction(title: "Ok", style: .cancel)
		ac.addAction(dismissBtn)
		present(ac, animated: true)
	}
	
	@objc func didChangeEmailField(){
		viewModel.email = emailTextfield.text
		viewModel.validateForm()
	}
	
	@objc func didChangePasswordField(){
		viewModel.password = passwordTextfield.text
		viewModel.validateForm()
	}
	
	@objc func didTapElsewhere(){
		view.endEditing(true)
	}
	
	private func configureConstraints(){
		let safe = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			registerLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 30),
			registerLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 100),
			
			emailTextfield.topAnchor.constraint(equalTo: registerLabel.bottomAnchor, constant: 30),
			emailTextfield.leftAnchor.constraint(equalTo: registerLabel.leftAnchor),
			emailTextfield.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -30),
			emailTextfield.heightAnchor.constraint(equalToConstant: 60),
			
			passwordTextfield.topAnchor.constraint(equalTo: emailTextfield.bottomAnchor, constant: 20),
			passwordTextfield.leftAnchor.constraint(equalTo: emailTextfield.leftAnchor),
			passwordTextfield.rightAnchor.constraint(equalTo: emailTextfield.rightAnchor),
			passwordTextfield.heightAnchor.constraint(equalToConstant: 60),
			
			signUpBtn.rightAnchor.constraint(equalTo: passwordTextfield.rightAnchor),
			signUpBtn.topAnchor.constraint(equalTo: passwordTextfield.bottomAnchor, constant: 20),
			signUpBtn.widthAnchor.constraint(equalToConstant: 180),
			signUpBtn.heightAnchor.constraint(equalToConstant: 50),
		])
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .systemBackground
		
		// dismiss keyboard when outside is tapped
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapElsewhere)))
		
		
		view.addSubview(registerLabel)
		view.addSubview(emailTextfield)
		view.addSubview(passwordTextfield)
		view.addSubview(signUpBtn)
		
		configureConstraints()
		bindViews()

    }
    
}
