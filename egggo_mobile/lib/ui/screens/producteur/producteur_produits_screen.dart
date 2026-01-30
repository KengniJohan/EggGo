import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/producteur_provider.dart';
import '../../../data/providers/produit_provider.dart';
import '../../../data/models/produit.dart';

/// Écran de gestion des produits pour les producteurs
class ProducteurProduitsScreen extends StatefulWidget {
  const ProducteurProduitsScreen({super.key});

  @override
  State<ProducteurProduitsScreen> createState() => _ProducteurProduitsScreenState();
}

class _ProducteurProduitsScreenState extends State<ProducteurProduitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProducteurProvider>().loadProduits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Produits'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProducteurProvider>().loadProduits(),
          ),
        ],
      ),
      body: Consumer<ProducteurProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.produits.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.produits.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProduits(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.produits.length,
              itemBuilder: (context, index) {
                return _ProduitCard(produit: provider.produits[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.egg_alt_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun produit',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Publiez vos offres d\'oeufs\npour commencer à vendre',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un produit'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddProductSheet(),
    );
  }
}

/// Carte de produit avec actions
class _ProduitCard extends StatelessWidget {
  final Produit produit;

  const _ProduitCard({required this.produit});

  @override
  Widget build(BuildContext context) {
    final isEnRupture = produit.stockDisponible <= 0;
    final isDisponible = produit.disponible;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isEnRupture ? Colors.red.withOpacity(0.3) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image du produit
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: produit.imageUrl != null && produit.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            produit.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.egg,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                          ),
                        )
                      : const Icon(Icons.egg, color: AppTheme.primaryColor, size: 32),
                ),
                const SizedBox(width: 12),
                
                // Infos du produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              produit.nom,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Menu d'actions
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (value) => _handleMenuAction(context, value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'modifier',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'stock',
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory, size: 18),
                                    SizedBox(width: 8),
                                    Text('Mettre à jour le stock'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'supprimer',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 18),
                                    SizedBox(width: 8),
                                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (produit.categorie != null)
                        Text(
                          produit.categorie!.nom,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${produit.prix.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (produit.unite != null) ...[
                            Text(
                              ' / ${produit.unite}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Barre de statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stock
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: isEnRupture ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEnRupture
                          ? 'Rupture de stock'
                          : 'Stock: ${produit.stockDisponible}',
                      style: TextStyle(
                        color: isEnRupture ? Colors.red : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: isEnRupture ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                
                // Switch disponibilité
                Row(
                  children: [
                    Text(
                      isDisponible ? 'Disponible' : 'Indisponible',
                      style: TextStyle(
                        color: isDisponible ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch.adaptive(
                      value: isDisponible,
                      onChanged: (value) async {
                        await context.read<ProducteurProvider>().toggleDisponibilite(produit.id);
                      },
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'modifier':
        _showEditDialog(context);
        break;
      case 'stock':
        _showStockDialog(context);
        break;
      case 'supprimer':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddProductSheet(produit: produit),
    );
  }

  void _showStockDialog(BuildContext context) {
    final stockController = TextEditingController();
    String operation = 'AJOUTER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Mettre à jour le stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stock actuel: ${produit.stockDisponible}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              
              // Choix de l'opération
              Row(
                children: [
                  Expanded(
                    child: _buildOperationChip(
                      context,
                      'AJOUTER',
                      'Ajouter',
                      Icons.add,
                      Colors.green,
                      operation,
                      (val) => setState(() => operation = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOperationChip(
                      context,
                      'RETIRER',
                      'Retirer',
                      Icons.remove,
                      Colors.orange,
                      operation,
                      (val) => setState(() => operation = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOperationChip(
                      context,
                      'DEFINIR',
                      'Définir',
                      Icons.edit,
                      Colors.blue,
                      operation,
                      (val) => setState(() => operation = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: operation == 'DEFINIR' ? 'Nouveau stock' : 'Quantité',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantite = int.tryParse(stockController.text);
                if (quantite != null && quantite > 0) {
                  final success = await context.read<ProducteurProvider>().updateStock(
                    produit.id,
                    quantite,
                    operation,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Stock mis à jour'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Voulez-vous vraiment supprimer "${produit.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<ProducteurProvider>().deleteProduit(produit.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produit supprimé'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet pour ajouter/modifier un produit
class _AddProductSheet extends StatefulWidget {
  final Produit? produit;

  const _AddProductSheet({this.produit});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prixController;
  late final TextEditingController _stockController;
  String _unite = 'alvéole';
  int? _categorieId;
  bool _isLoading = false;

  bool get isEditing => widget.produit != null;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.produit?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.produit?.description ?? '');
    _prixController = TextEditingController(text: widget.produit?.prix.toStringAsFixed(0) ?? '');
    _stockController = TextEditingController(text: widget.produit?.stockDisponible.toString() ?? '');
    _unite = widget.produit?.unite ?? 'alvéole';
    _categorieId = widget.produit?.categorie?.id;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProduitProvider>().categories;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'Modifier le produit' : 'Nouveau produit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Nom du produit
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  hintText: 'Ex: Œufs de poule locaux',
                  prefixIcon: Icon(Icons.egg_alt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du produit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Catégorie
              if (categories.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  value: _categorieId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories.map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.nom),
                  )).toList(),
                  onChanged: (value) => setState(() => _categorieId = value),
                  validator: (value) {
                    if (value == null) return 'Veuillez sélectionner une catégorie';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez votre produit...',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Prix et Unité
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _prixController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix (FCFA) *',
                        hintText: '2500',
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requis';
                        if (double.tryParse(value) == null) return 'Prix invalide';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unite,
                      decoration: const InputDecoration(labelText: 'Unité'),
                      items: const [
                        DropdownMenuItem(value: 'alvéole', child: Text('Alvéole')),
                        DropdownMenuItem(value: 'pièce', child: Text('Pièce')),
                        DropdownMenuItem(value: 'carton', child: Text('Carton')),
                        DropdownMenuItem(value: 'plateau', child: Text('Plateau')),
                      ],
                      onChanged: (value) => setState(() => _unite = value ?? 'alvéole'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock disponible
              if (!isEditing)
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock disponible *',
                    hintText: 'Quantité en stock',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer la quantité';
                    if (int.tryParse(value) == null) return 'Quantité invalide';
                    return null;
                  },
                ),
              const SizedBox(height: 24),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditing ? 'Enregistrer les modifications' : 'Publier le produit'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ProducteurProvider>();
      bool success;

      if (isEditing) {
        // TODO: Implement update
        success = true;
      } else {
        success = await provider.createProduit(
          nom: _nomController.text.trim(),
          description: _descriptionController.text.trim(),
          prix: double.parse(_prixController.text),
          quantiteStock: int.parse(_stockController.text),
          categorieId: _categorieId ?? 1,
          unite: _unite,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Produit modifié' : 'Produit ajouté avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
