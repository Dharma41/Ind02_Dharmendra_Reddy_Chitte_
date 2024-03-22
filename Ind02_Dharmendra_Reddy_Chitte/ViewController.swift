//
//  ViewController.swift
//  Ind02_Dharmendra_Reddy_Chitte
//
//  Created by DHARMENDRA REDDY CHITTE on 2/27/24.
//
import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var Namelabel: UILabel!
    var collectionView: UICollectionView!
    
    private var shuffleButton: UIButton!
    private var showAnswerButton: UIButton!
    
    private var tiles: [Int] = Array(0..<20) // Tiles for the puzzle
    private let originalTiles = Array(0..<20) // Original order of tiles
    private var tilesBeforeShowingAnswer: [Int]? // Store tiles before showing the answer
    
    private var isShowingAnswer = false // Flag to track if answer is currently shown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray // Set the background color of the root view
        
        setupCollectionView()
        setupButtons()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 93, height: 93)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: Namelabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 465)
        ])
    }
    
    func setupButtons() {
        shuffleButton = UIButton(type: .system)
        shuffleButton.setTitle("Shuffle", for: .normal)
        shuffleButton.addTarget(self, action: #selector(shuffleAction), for: .touchUpInside)
        shuffleButton.backgroundColor = .blue // Set the background color
        shuffleButton.setTitleColor(.white, for: .normal) // Set the title color to ensure it's visible
        shuffleButton.layer.cornerRadius = 5 // Optional: Adds rounded corners
        
        showAnswerButton = UIButton(type: .system)
        showAnswerButton.setTitle("Show Answer", for: .normal)
        showAnswerButton.addTarget(self, action: #selector(showAnswerAction), for: .touchUpInside)
        showAnswerButton.backgroundColor = .red // Set the background color
        showAnswerButton.setTitleColor(.white, for: .normal) // Set the title color to ensure it's visible
        showAnswerButton.layer.cornerRadius = 10 // Optional: Adds rounded corners
        
        shuffleButton.translatesAutoresizingMaskIntoConstraints = false
        showAnswerButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(shuffleButton)
        view.addSubview(showAnswerButton)
        
        NSLayoutConstraint.activate([
            shuffleButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            shuffleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            shuffleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shuffleButton.heightAnchor.constraint(equalToConstant: 44),
            
            showAnswerButton.topAnchor.constraint(equalTo: shuffleButton.bottomAnchor, constant: 8),
            showAnswerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            showAnswerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            showAnswerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    
    // UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        configureCell(cell, forItemAt: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let imageViewTag = 100
        if let imageView = cell.contentView.viewWithTag(imageViewTag) as? UIImageView {
            imageView.image = UIImage(named: "\(tiles[indexPath.row])")
        } else {
            let imageView = UIImageView(frame: cell.bounds)
            imageView.image = UIImage(named: "\(tiles[indexPath.row])")
            imageView.contentMode = .scaleAspectFill
            imageView.tag = imageViewTag
            cell.contentView.addSubview(imageView)
        }
    }
    
    // Button Actions
    @objc func shuffleAction(sender: UIButton) {
        shuffleTiles()
        checkPuzzleSolved()
    }
    
    @objc func showAnswerAction(sender: UIButton) {
        isShowingAnswer.toggle()
        if isShowingAnswer {
            tilesBeforeShowingAnswer = tiles
            tiles = originalTiles
        } else {
            if let savedTiles = tilesBeforeShowingAnswer {
                tiles = savedTiles
                tilesBeforeShowingAnswer = nil
            }
        }
        let title = isShowingAnswer ? "Hide Answer" : "Show Answer"
        showAnswerButton.setTitle(title, for: .normal)
        collectionView.reloadData()
    }
    
    // Puzzle Manipulation
    private func shuffleTiles() {
        var lastIdx = -1 // Initialize with an invalid index
        for _ in 0..<Int.random(in: 10...25) {
            let emptyIndex = tiles.firstIndex(of: 0)! // Find the current position of the empty space
            var adjacentIndices = findAdjacentIndices(of: emptyIndex)
            
            // To add more randomness and avoid potentially reversing the immediate last move,
            // remove the last index (if it exists) from the adjacent indices.
            if lastIdx != -1 {
                adjacentIndices.removeAll(where: { $0 == lastIdx })
            }
            
            if let randomAdjacentIndex = adjacentIndices.randomElement() {
                tiles.swapAt(emptyIndex, randomAdjacentIndex)
                lastIdx = emptyIndex // The last index becomes the current empty space's index after swap
            }
        }
        collectionView.reloadData()
    }
    private func findAdjacentIndices(of index: Int) -> [Int] {
        var adjacentIndices: [Int] = []
        // Check left
        if index % 4 != 0 {
            adjacentIndices.append(index - 1)
        }
        // Check right
        if index % 4 != 3 {
            adjacentIndices.append(index + 1)
        }
        // Check top
        if index >= 4 {
            adjacentIndices.append(index - 4)
        }
        // Check bottom
        if index < 16 {
            adjacentIndices.append(index + 4)
        }
        return adjacentIndices
    }
    
    private func checkPuzzleSolved() {
        if tiles == originalTiles {
            // Puzzle solved, update button appearance
            shuffleButton.setTitle("Solved! Shuffle Again?", for: .normal)
            shuffleButton.setTitleColor(.green, for: .normal) // Change color to indicate solved puzzle
        } else {
            // Puzzle not solved, restore original button appearance
            shuffleButton.setTitle("Shuffle", for: .normal)
            shuffleButton.setTitleColor(.systemBlue, for: .normal) // Use your default button color here
        }
    }
    
    // UICollectionViewDelegate method
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isShowingAnswer else { return } // Ignore taps when answer is shown
        let emptyIndex = tiles.firstIndex(of: 0)!
        let adjacentIndices = findAdjacentIndices(of: indexPath.row)
        if adjacentIndices.contains(emptyIndex) {
            // Tapped tile is adjacent to the hole, perform move
            tiles.swapAt(indexPath.row, emptyIndex)
            collectionView.reloadData()
            // Check if puzzle is solved
            checkPuzzleSolved()
        }
    }
}

