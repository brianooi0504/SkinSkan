//
//  InformationViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

class InformationViewController: UITableViewController {
    static var diseases: [Disease] =
    [Disease(name: "Eczema (Dermatitis)",
             desc: "Eczema is a group of conditions that make your skin inflamed or irritated. The most common type is atopic dermatitis or atopic eczema. “Atopic” refers to a person’s tendency to get allergic conditions such as asthma and hay fever.",
             similar: "Psoriasis, Scabies, Hives (Urticaria)",
             symptom: "Eczema looks different for everyone. And your flare-ups won’t always happen in the same area. No matter which part of your skin is affected, eczema is almost always itchy. The itching sometimes starts before the rash. Your skin may also be red, dry, cracked, or leathery.",
             treatment: "Moisturizers, hydrocortisone creams, antihistamines, colloidal oatmeal, wet wraps, calamine lotion, and other medications. Talk to your doctor to know more.",
             link: "https://www.webmd.com/skin-problems-and-treatments/eczema/atopic-dermatitis-eczema",
            images: [UIImage(named: "ad1")!, UIImage(named: "ad2")!, UIImage(named: "ad3")!, UIImage(named: "ad4")!]),
     Disease(name: "Urticaria",
             desc: "Urticaria, also known as hives, is an outbreak of pale red bumps or welts on the skin that appear suddenly. The swelling that often comes with hives is called angioedema. Allergic reactions, chemicals in certain foods, insect stings, sunlight, and medications can cause hives. It's often impossible to find out exactly why hives have formed.",
             similar: "Heat rash, contact dermatitis, rosacea, eczema, pityriasis rosea",
             symptom: "Welts that might be red, purple or skin-colored, depending on your skin color. Welts that vary in size, change shape, and appear and fade repeatedly. Itchiness (pruritus), which can be intense. Painful swelling (angioedema) around the eyes, cheeks or lips.",
             treatment: "Antihistamines, omalizumad (Xolair), epinephrine, cortisone, and other medications. Talk to your doctor to know more.",
             link: "https://www.webmd.com/skin-problems-and-treatments/guide/hives-urticaria-angioedema",
             images: [UIImage(named: "urt1")!, UIImage(named: "urt2")!, UIImage(named: "urt3")!, UIImage(named: "urt4")!]),
    Disease(name: "Psoriasis",
            desc: "Psoriasis is a skin disorder that causes skin cells to multiply up to 10 times faster than normal. This makes the skin build up into bumpy red patches covered with white scales. They can grow anywhere, but most appear on the scalp, elbows, knees, and lower back. Psoriasis can't be passed from person to person. It does sometimes happen in members of the same family.",
            similar: "Eczema, seborrheic dermatitis, pityriasis rosea.",
            symptom: "Dry skin lesions, known as plaques, covered in scales. They normally appear on your elbows, knees, scalp and lower back, but can appear anywhere on your body. The plaques can be itchy or sore, or both. In severe cases, the skin around your joints may crack and bleed.",
            treatment: "Steroid creams, moisturizers for dry skin, coal tar, Vitamin D-based cream or ointment, retinoid creams, light therapy, and others. Talk to your doctor to know more.",
            link: "https://www.webmd.com/skin-problems-and-treatments/psoriasis/understanding-psoriasis-basics",
            images: [UIImage(named: "pso1")!, UIImage(named: "pso2")!, UIImage(named: "pso3")!, UIImage(named: "pso4")!]),
    Disease(name: "Tinea corporis (Ringworm)",
            desc: "Ringworm isn’t a worm. It’s a skin infection that’s caused by mold-like fungi that live on the dead tissues of your skin, hair, and nails. You can get it in any of these places -- and on your scalp. When you get it between your toes, it’s what people call athlete’s foot. If it spreads to your groin, it’s known as jock itch.",
            similar: "Nummular eczema, granuloma annulare, seborrhea, psoriasis, pityriasis",
            symptom: "The telltale sign is a red, scaly patch or bump that itches. Over time, the bump turns into a ring- or circle-shaped patch. It may turn into several rings. The inside of the patch is usually clear or scaly. The outside might be slightly raised and bumpy.",
            treatment: "OTC antifungal cream, lotion, powder, clotrimazole (Lotrimin, Mycelex), miconazole, and others. Talk to your doctor to know more",
            link: "https://www.webmd.com/skin-problems-and-treatments/what-you-should-know-about-ringworm",
            images: [UIImage(named: "tin1")!, UIImage(named: "tin2")!, UIImage(named: "tin3")!, UIImage(named: "tin4")!]),
    Disease(name: "Vitiligo",
            desc: "Vitiligo is a condition in which white patches develop on the skin. Any location on the body can be affected, and most people with vitiligo have white patches on many areas.",
            similar: "Sarcoidosis, pityriasis versicolor, thermal burns, psoriasis, leprosy",
            symptom: "You'll often lose pigment quickly on several areas of your skin. After the white patches appear, they may stay the same for a while, but later on, they might get bigger. You may have cycles of pigment loss and stability.",
            treatment: "There's no known way to prevent or cure vitiligo. Talk to your doctor to know more.",
            link: "https://www.webmd.com/skin-problems-and-treatments/guide/vitiligo-common-cause-loss-skin-pigment",
           images: [UIImage(named: "vit1")!, UIImage(named: "vit2")!, UIImage(named: "vit3")!, UIImage(named: "vit4")!]),
    Disease(name: "Scabies",
            desc: "Scabies, or human itch mites, are eight-legged critters that burrow into the upper layer of your skin. There, they lay eggs. Once the eggs hatch, the mites climb to the surface of your skin, where they spread to other parts of your body. They can also spread to other people.",
            similar: "Psoriasis, eczema, contact dermatitis",
            symptom: "Your first signs that something is wrong will be intense itching (especially at night), and a pimple-like rash. You might notice these symptoms all over your body. Or they may be limited to certain areas, like your wrist, elbows, genitals, butt, or the webbing between your fingers. You might also notice burrows on your skin. These are tiny, raised, grayish-white or flesh-colored lines on your body. They’re caused by the mites digging their way into your skin.",
            treatment: "Scabicide lotion, cream, and other antibiotic creams. Talk to your doctor to know more.",
            link: "https://www.webmd.com/skin-problems-and-treatments/scabies-do-you-have-them",
            images: [UIImage(named: "sca1")!, UIImage(named: "sca2")!, UIImage(named: "sca3")!, UIImage(named: "sca4")!])]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InformationViewController.diseases.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as? InformationCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = InformationViewController.diseases[indexPath.row].name
        
        var imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width: 100, height: 200))
        let image = InformationViewController.diseases[indexPath.row].images[0]
        cell.backgroundColor = UIColor.clear
        imageView = UIImageView(image:image)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.5
        cell.backgroundView = imageView
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InformationDetailSegue" {
            if let destination = segue.destination as? InformationDetailViewController,
               let selectedCell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: selectedCell) {
                let rowIndex = indexPath.row
                let selectedDisease: Disease = InformationViewController.diseases[rowIndex]
                destination.configure(disease: selectedDisease)
            }
        }
    }
    
}
