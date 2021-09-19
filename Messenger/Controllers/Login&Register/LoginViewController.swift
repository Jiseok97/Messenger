//
//  LoginViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/10.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    // MARK: View 선언
    private let scrollView : UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        // clipsToBounds → ture일 때, 내용들과 서브뷰들은 뷰의 테두리를 기준으로 잘리게 된다.(defualt → false)
        return scrollView
    }()

    private let imageView : UIImageView = {
       let imgView = UIImageView()
        imgView.image = UIImage(named: "logo")
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let emailField : UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none   // 자동 대문자 X
        field.autocorrectionType = .no   // 자동 수정 X
        field.returnKeyType = .continue   // 다음으로 넘어갈 수 있게 (PW TF)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "이메일 입력..."
        
        field.clearButtonMode = .always
        field.clearButtonMode = .whileEditing
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField : UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none   // 자동 대문자 X
        field.autocorrectionType = .no   // 자동 수정 X
        field.returnKeyType = .continue   // 다음으로 넘어갈 수 있게 (Log in Btn)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "비밀번호 입력..."
        
        field.clearButtonMode = .always
        field.clearButtonMode = .whileEditing
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let loginBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("로그인", for: .normal)
        btn.backgroundColor = .link
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return btn
    }()
    
    private let fbLoginButton : FBLoginButton = {
        let button = FBLoginButton()
        // 권한 저장
        button.permissions = ["email", "public_profile"]
        
        return button
    }()
    
    
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    // MARK: SetUI()
    func setUI() {
        title = "로그인"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "회원가입",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginBtn.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside)
        fbLoginButton.layer.cornerRadius = 12
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginBtn)
        scrollView.addSubview(fbLoginButton)
    }
    
    // MARK: View Frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                y: 60,
                                width: size,
                                height: size)
        
        emailField.frame = CGRect(x: 30,
                                 y: imageView.bottom + 30,
                                 width: scrollView.width - 60,
                                 height: 47)
        
        passwordField.frame = CGRect(x: 30,
                                    y: emailField.bottom + 10,
                                    width: scrollView.width - 60,
                                    height: 47)
        
        loginBtn.frame = CGRect(x: 30,
                               y: passwordField.bottom + 23,
                               width: scrollView.width - 60,
                               height: 47)
        
        fbLoginButton.frame = CGRect(x: 30,
                               y: loginBtn.bottom + 12,
                               width: scrollView.width - 60,
                               height: 40)
    }
    
    
    // MAKR: 일반 로그인 버튼 Action
    @objc private func loginBtnTapped() {
        // resignFirstResponder → 키보드 숨기기
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        // MARK: Firebase 로그인
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                // 로그인 실패
                print("로그인 실패 \(email)")
                return
            }
            // 로그인 성공
            let user = result.user
            print("로그인 성공: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    // MARK: 로그인 실패 시
    func alertUserLoginError() {
        let alert = UIAlertController(title: "로그인 실패",
                                     message: "이메일 혹은 비밀번호를 다시 확인해주세요",
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    
    // MARK: 회원가입 버튼 및 이동
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            // 이메일에서 비밀번호 TF로 포커스 될 수 있도록
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginBtnTapped()
        }
        
        return true
    }
}


// MARK: 페이스북 로그인 기능
extension LoginViewController : LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // LoginManagerLoginResult 반환은 클래스반환, 토큰 반환
        guard let token = result?.token?.tokenString else {
            print("페이스북 로그인을 실패하였습니다.")
            return
        }
        // 자격 증명을 얻기 위한 ...
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard authResult != nil, error == nil else {
                print("페이스북 로그인 실패, MFA가 필요합니다.")
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            print("페이스북 로그인 성공하셨습니다.")
        })
        
    }
    
    // FB 유저가 로그인 한 것을 감지하면 로그인 버튼을 자동으로 로그아웃 버튼으로 표시하도록 버튼이 업데이트 됨
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // 필요 없을듯 !
    }
}
