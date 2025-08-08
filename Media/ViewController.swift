//
//  ViewController.swift
//  Media
//
//  Created by shafia on 08/08/2025.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = true
        return sv
    }()
    
    let filtersStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Properties
    let filterNames = [
        "CISepiaTone": "Sepia",
        "CIPhotoEffectMono": "Mono",
        "CIPhotoEffectChrome": "Chrome",
        "CIPhotoEffectFade": "Fade",
        "CIPhotoEffectInstant": "Instant",
        "CIPhotoEffectNoir": "Noir",
        "CIPhotoEffectProcess": "Process",
        "CIPhotoEffectTonal": "Tonal",
        "CIColorInvert": "Invert",
        "CIColorControls": "Vibrant",
        "CIVignette": "Vignette",
        "CIBloom": "Bloom"
    ]
    
    var originalImage: UIImage?
    private var filtersArray: [(key: String, value: String)] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersArray = Array(filterNames)
        setupUI()
        loadOriginalImage()
        createFilterButtons()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(filtersStackView)
        
        // Add image view
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            // Image view constraints
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            // Scroll view constraints
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scrollView.heightAnchor.constraint(equalToConstant: 60),
            
            // Stack view constraints - critical changes here
            filtersStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            filtersStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            filtersStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            filtersStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            filtersStackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    private func loadOriginalImage() {
        guard let image = UIImage(named: "image") else {
            print("Error: Could not load image named 'image' from assets")
            return
        }
        originalImage = image
        imageView.image = image
    }
    
    // MARK: - Filter Buttons
    private func createFilterButtons() {
        for (index, (filterName, displayName)) in filtersArray.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(displayName, for: .normal)
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 8
            button.setTitleColor(.systemBlue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
            button.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            filtersStackView.addArrangedSubview(button)
        }
        
        // After adding all buttons, update the content size
        DispatchQueue.main.async {
            let totalWidth = self.filtersStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
            self.scrollView.contentSize = CGSize(width: totalWidth, height: 60)
        }
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        guard sender.tag < filtersArray.count else { return }
        
        let filterName = filtersArray[sender.tag].key
        applyFilter(name: filterName)
    }
    
    // MARK: - Filter Application
    func applyFilter(name: String, intensity: Float = 1.0) {
        guard let originalImage = originalImage,
              let ciImage = CIImage(image: originalImage) else {
            print("Error: Could not create CIImage from original image")
            return
        }
        
        guard let filter = CIFilter(name: name) else {
            print("Error: Could not create filter \(name)")
            return
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Set specific parameters for certain filters
        switch name {
        case "CISepiaTone":
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
        case "CIVignette":
            filter.setValue(intensity * 2, forKey: kCIInputIntensityKey)
            filter.setValue(intensity * 30, forKey: kCIInputRadiusKey)
        case "CIColorControls":
            filter.setValue(1.0, forKey: kCIInputSaturationKey)
            filter.setValue(0.1, forKey: kCIInputBrightnessKey)
            filter.setValue(1.1, forKey: kCIInputContrastKey)
        case "CIBloom":
            filter.setValue(5.0, forKey: kCIInputRadiusKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
        default:
            break
        }
        
        guard let outputImage = filter.outputImage else {
            print("Error: No output image from filter")
            return
        }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            print("Error: Could not create CGImage from CIImage")
            return
        }
        
        imageView.image = UIImage(cgImage: cgImage)
    }
    
    // Reset to original image
    @objc private func resetImage() {
        imageView.image = originalImage
    }
}
