//
//  PKMListViewController.swift
//  dex
//
//  Created by Josue Meza on 12/12/18.
//  Copyright © 2018 Josue Meza. All rights reserved.
//

import UIKit
import SwiftyUIEssentials
import SDWebImage

class PKMListViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var spriteGradientView: SEGradientView!
    @IBOutlet weak var spriteImageView: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var firstTypeBorderView: SEBorderView!
    @IBOutlet weak var firstTypeTitleLabel: UILabel!
    @IBOutlet weak var secondTypeBorderView: SEBorderView!
    @IBOutlet weak var secondTypeTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Attributes

    var pokemons = [Pokemon.ListItem]()
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Pokemon.list().done { pokemons in
            self.pokemons = pokemons
            if let first = pokemons.first {
                Pokemon.fetch(first).done { pokemon in
                    self.setData(of: pokemon)
                    self.tableView.reloadData()
                }.catch { error in
                    print(error.localizedDescription)
                }
            }
        }.catch { error in
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Methods
    
    private func setType(_ type: String?, with label: UILabel, on borderView: SEBorderView) -> UIColor? {
        borderView.isHidden = type == nil
        if let type = type {
            label.text = type.capitalized
            borderView.backgroundColor = Pokemon.PokemonType.color(for: type)
            return borderView.backgroundColor
        }
        return nil
    }
    
    private func setSprite(of url: URL?, to imageView: UIImageView, on gradientView: SEGradientView, with colors: [UIColor]) {
        imageView.sd_setImage(with: url)
        gradientView.gradientStartColor = colors[0]
        gradientView.gradientEndColor = colors[1]
    }
    
    private func setData(of pokemon: Pokemon) {
        indexLabel.text = "Nº \(pokemon.id)"
        nameLabel.text = pokemon.name?.capitalized
        let firstColor = setType(pokemon.firstType, with: firstTypeTitleLabel, on: firstTypeBorderView) ?? .white
        let secondColor = setType(pokemon.secondType, with: secondTypeTitleLabel, on: secondTypeBorderView) ?? .white
        setSprite(of: pokemon.spriteUrl, to: spriteImageView, on: spriteGradientView, with: [firstColor, secondColor])
    }

}

// MARK: -
extension PKMListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table view delegate and data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pokemon = pokemons[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = pokemon.name.capitalized
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Pokemon.fetch(pokemons[indexPath.row]).done { pokemon in
            self.setData(of: pokemon)
        }.catch { error in
            print(error.localizedDescription)
        }
        
    }
    
}
