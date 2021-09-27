//
//  RegisterViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/10.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    // 인디케이터
    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView : UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        // clipsToBounds → ture일 때, 내용들과 서브뷰들은 뷰의 테두리를 기준으로 잘리게 된다.(defualt → false)
        return scrollView
    }()

    private let imageView : UIImageView = {
       let imgView = UIImageView()
        imgView.image = UIImage(systemName: "person.circle")
        imgView.tintColor = .gray
        imgView.contentMode = .scaleAspectFit
        imgView.layer.masksToBounds = true   // imageView 둥글게 할 때 이미지 자르기
        imgView.layer.borderWidth = 1.5
        imgView.layer.borderColor = UIColor.lightGray.cgColor
        return imgView
    }()
    
    private let firstNameField : UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none   // 자동 대문자 X
        field.autocorrectionType = .no   // 자동 수정 X
        field.returnKeyType = .continue   // 다음으로 넘어갈 수 있게 (PW TF)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "성 입력..."
        
        field.clearButtonMode = .always
        field.clearButtonMode = .whileEditing
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField : UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none   // 자동 대문자 X
        field.autocorrectionType = .no   // 자동 수정 X
        field.returnKeyType = .continue   // 다음으로 넘어갈 수 있게 (PW TF)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "이름 입력..."
        
        field.clearButtonMode = .always
        field.clearButtonMode = .whileEditing
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
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
    
    private let registerBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("회원가입", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    func setUI() {
        title = "회원가입"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "회원가입",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        registerBtn.addTarget(self, action: #selector(registerBtnTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerBtn)
        
        // 사용자 상호작용
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfile))
        
        imageView.addGestureRecognizer(gesture)
    }
    
    
    // MARK: 프로필 이미지 클릭(이미지 변경)
    // Info 권한 추가
    @objc private func didTapChangeProfile() {
        presentPhotoActionSheet()   // delegate func
    }
    
    // MARK: width & height .. etc Extensions 정의
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2 - 22,
                                y: 40,
                                width: size + 50,
                                height: size + 50)
        
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        firstNameField.frame = CGRect(x: 30,
                                 y: imageView.bottom + 20,
                                 width: scrollView.width - 60,
                                 height: 47)
        
        lastNameField.frame = CGRect(x: 30,
                                 y: firstNameField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 47)
        
        emailField.frame = CGRect(x: 30,
                                 y: lastNameField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 47)
        
        passwordField.frame = CGRect(x: 30,
                                    y: emailField.bottom + 10,
                                    width: scrollView.width - 60,
                                    height: 47)
        
        registerBtn.frame = CGRect(x: 30,
                               y: passwordField.bottom + 23,
                               width: scrollView.width - 60,
                               height: 47)
    }
    
    
    @objc private func registerBtnTapped() {
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // 유효성 검사
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase 회원가입
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                // 사용자가 이미 존재함
                strongSelf.alertUserLoginError(message: "입력하신 이메일은 이미 사용중인 이메일입니다.")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("회원가입 에러 발생")
                    return
                }
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        // 사진 업로드
                        guard let image = strongSelf.imageView.image, let data = image.pngData() else {
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
                    }
                })
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func alertUserLoginError(message: String = "회원정보를 다시 확인하여 주세요") {
        let alert = UIAlertController(title: "회원가입 실패",
                                     message: message,
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            // 이메일에서 비밀번호 TF로 포커스 될 수 있도록
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerBtnTapped()
        }
        
        return true
    }
}


extension RegisterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "프로필 사진",
                                           message: "프로필 사진을 수정하시겠습니까?",
                                           preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "확인",
                                           style: .cancel,
                                           handler: nil))
        actionSheet.addAction(UIAlertAction(title: "카메라",
                                           style: .default,
                                           handler: { [weak self] _ in
                                            
                                            self?.presentCamera()
                                            
                                           }))
        actionSheet.addAction(UIAlertAction(title: "라이브러리",
                                           style: .default,
                                           handler: { [weak self] _ in
                                            
                                            self?.presentPhotoPicker()
                                            
                                           }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true   // 편집 허용
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    // 이미지 가져오는 기능
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
