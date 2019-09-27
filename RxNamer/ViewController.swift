//
//  ViewController.swift
//  RxNamer
//
//  Created by MacBook on 9/27/19.
//  Copyright © 2019 Shakhboz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    // Outlets
    @IBOutlet weak var helloLbl: UILabel!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var namesLbl: UILabel!
    @IBOutlet weak var addNameBtn: UIButton!
    
    let disposeBag = DisposeBag()
    var namesArray: Variable<[String]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTextField()
        bindSubmitButton()
        bindAddNameButton()
        
        namesArray.asObservable().subscribe(onNext: { names in
            self.namesLbl.text = names.joined(separator: ", ")
            }).disposed(by: disposeBag)
    }

    func bindTextField() {
        nameTxtField.rx.text
            .map {
                if $0 == "" {
                    return "Type your name below."
                } else {
                    return "Hello, \($0!)."
                }
        }
        .bind(to: helloLbl.rx.text)
        .disposed(by: disposeBag)
    }

    func bindSubmitButton() {
        submitBtn.rx.tap.subscribe(onNext: {
            if self.nameTxtField.text != "" {
                self.namesArray.value.append(self.nameTxtField.text!)
                self.namesLbl.rx.text.onNext(self.namesArray.value.joined(separator: ", "))
                self.nameTxtField.rx.text.onNext("")
                self.helloLbl.rx.text.onNext("Type your name below.")
            }
        }).disposed(by: disposeBag)
    }
    
    func bindAddNameButton() {
        addNameBtn.rx.tap.throttle(0.5, scheduler: MainScheduler.instance).subscribe(onNext: {
            
            guard let addNameVC = self.storyboard?.instantiateViewController(identifier: "AddNameVC") as? AddNameVC else { fatalError("Couldn't create AddNameVC")}
            addNameVC.nameSubject.subscribe(onNext: { name in
                self.namesArray.value.append(name)
                addNameVC.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
            
            self.present(addNameVC, animated: true, completion: nil)
        })
    }
}

