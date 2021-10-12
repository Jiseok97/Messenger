//
//  LoginViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/10.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    // 인디케이터
    private let spinner = JGProgressHUD(style: .dark)
    
    // 구글 클라이언트 ID
    let signInConfig = GIDConfiguration.init(clientID: (FirebaseApp.app()?.options.clientID)!)
    
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
    
    private let mLabel : UILabel = {
        let lbl = UILabel()
        lbl.text = "JS Messenger"
        lbl.textColor = UIColor.link
        lbl.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return lbl
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
    
    private let googleLogInButton = GIDSignInButton()
    private var loginObserver : NSObjectProtocol?
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 원래 구글로그인을 App Delegate에서 작업했다면..
        // 로그인이 되었다면 앱 전반에 걸친 알림과 이를 듣고 있는 옵저버(관찰자)가 필요함
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
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
        googleLogInButton.addTarget(self, action: #selector(googleLogInTapped), for: .touchUpInside)
        fbLoginButton.layer.cornerRadius = 12
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(mLabel)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginBtn)
        scrollView.addSubview(fbLoginButton)
        scrollView.addSubview(googleLogInButton)
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
        
        mLabel.frame = CGRect(x: (scrollView.width - size) / 2 - 10,
                                y: imageView.bottom + 12,
                                width: scrollView.width - 60,
                                height: 50)
        
        emailField.frame = CGRect(x: 30,
                                 y: mLabel.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 47)
        
        passwordField.frame = CGRect(x: 30,
                                    y: emailField.bottom + 10,
                                    width: scrollView.width - 60,
                                    height: 47)
        
        loginBtn.frame = CGRect(x: 30,
                               y: passwordField.bottom + 16,
                               width: scrollView.width - 60,
                               height: 47)
        
        fbLoginButton.frame = CGRect(x: 30,
                               y: loginBtn.bottom + 12,
                               width: scrollView.width - 60,
                               height: 40)
        
        googleLogInButton.frame = CGRect(x: 30,
                                         y: fbLoginButton.bottom + 12,
                                         width: scrollView.width - 60,
                                         height: 40)
    }
    
    // Observer
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: 구글 로그인 기능
    @objc private func googleLogInTapped() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            guard let googleEmail = user.profile?.email,
                  let fullName = user.profile?.name else { return }
            
            UserDefaults.standard.set(googleEmail, forKey: "email")
            UserDefaults.standard.set(fullName, forKey: "name")
            
            DatabaseManager.shared.userExists(with: googleEmail, completion: { exists in
                if !exists {
                    // 사용자 정보 데이터베이스에 넣기
                    let chatUser = ChatAppUser(firstName: fullName,
                                               lastName: "",
                                               emailAddress: googleEmail)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            // 사진 업로드
                            if user.profile!.hasImage {
                                guard let url = user.profile?.imageURL(withDimension: 200) else {
                                    return
                                }
                                
                                URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                    guard let data = data else {
                                        return
                                    }
                                    let fileName = chatUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                        switch result {
                                        case .success(let downloadUrl) :
                                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                            print(downloadUrl)
                                            
                                        case .failure(let error):
                                            print("이미지 저장소 관리자 에러: \(error)")
                                        }
                                    })
                                }).resume()
                            }
                        }
                    })
                }
            })
            
            user.authentication.do { authentication, error in
                guard error == nil else { return }
                guard let authentication = authentication else { return }
                
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!,
                                                               accessToken: authentication.accessToken)
                
                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                    guard authResult != nil, error == nil else {
                        print("로그인 뷰 → 구글 로그인 실패")
                        return
                    }
                    print("로그인 뷰 → 구글 로그인 성공")
                    // 그냥 dismiss해도 되지만, Notification으로 구성해봤다..
                    // 원래 Google Login은 AppDelegate에서 기능을 확장시켰는데 왜인지 최근에 로그인 방식이 변했다...
                    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                })
                
            }
        }
    }
    
    
    // MARK: 일반 로그인 버튼 Action
    @objc private func loginBtnTapped() {
        // resignFirstResponder → 키보드 숨기기
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // MARK: Firebase 로그인
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                // 로그인 실패
                print("로그인 실패 \(email)")
                return
            }
            // 로그인 성공
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                            
                case .failure(let error):
                    print("데이터를 읽는데 실패하였습니다. → LoginVC \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
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


// MARK: 페이스북 로그인 기능 & 사진
extension LoginViewController : LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // LoginManagerLoginResult 반환은 클래스반환, 토큰 반환
        guard let token = result?.token?.tokenString else {
            print("페이스북 로그인을 실패하였습니다.")
            return
        }
        
        // Firebase 데이터 시각화를 위함, FB 엑세스 토큰전까지
        let fbRequest = FBSDKLoginKit.GraphRequest(graphPath: "Me",
                                                  parameters: ["fields":
                                                                "email, name, picture.type(large)"],
                                                  tokenString: token,
                                                  version: nil,
                                                  httpMethod: .get)
        
        // 해당 이메일 및 이름을 가져오기 위함
        fbRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any],
                      error == nil else {
                print("페이스북 그래프 요청에 실패하였습니다.")
                return
            }
            // return(result) => User Name, User Id, User Email
            print("페이스북 reulst => \(result)")
            // result => 딕셔너리[Key]
            guard let fullName = result["name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                print("유저의 이름 및 이메일 가져오기를 페이스북 로그인에서 실패였습니다.")
                
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(fullName, forKey: "name")
            
            // 같은 이름 및 이메일이 존재하지 않으면 DB에 유저 정보 넣어주기 ! (중복 검사)
            // MARK: 페이스북 이미지 업로드(URL)
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: fullName,
                                               lastName: "",
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            // 사진 업로드
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("페이스북 사진 다운로드를 진행합니다.")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    print("데이터를 가져오는데 실패하였습니다. (페이스북_이미지)")
                                    return
                                }
                                
                                print("페이스북으로부터 데이터를 업로딩합니다...")
                                
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl) :
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                        
                                    case .failure(let error):
                                        print("이미지 저장소 관리자 에러: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            
            
            // 페이스북 엑세스 토큰을 교환하여 Firebase 자격 증명을 얻기 !!
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                // 메모리 누수때문에 weak self 사용
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    // Firebase에 사용 설정하면 됨 !!
                    print("페이스북 로그인 실패, MFA가 필요합니다.")
                    return
                }
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                print("페이스북 로그인 성공하셨습니다.")
            })
        })
        
    }
    
    // FB 유저가 로그인 한 것을 감지하면 로그인 버튼을 자동으로 로그아웃 버튼으로 표시하도록 버튼이 업데이트 됨
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // 필요 없을듯 !
    }
}

