import 'package:flutter/material.dart';
import 'package:rustic_fit/screens/payment_screen.dart';
import '../models/dummy_data.dart';
import '../services/data_service.dart';

class AddRequestScreen extends StatefulWidget {
  final Product product;

  const AddRequestScreen({super.key, required this.product});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final Color primaryBrown = const Color(0xFF5D4037);
  final Color accentBrown = const Color(0xFFA67C52);

  String _selectedSize = '';
  int _quantity = 1;
  String _selectedAddress = '';
  String _specialInstructions = '';
  String _selectedTailorId = '';
  DateTime? _selectedDate;
  String _selectedTimeSlot = '';
  bool _isStoreSelection = true;

  @override
  void initState() {
    super.initState();
    // Set default size if available
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }

    // Set default address if available
    final user = DataService().getCurrentUser();
    if (user.savedAddresses.isNotEmpty) {
      _selectedAddress = user.savedAddresses.first;
    }

    // Set default tailor if available
    final tailors = DataService().getAvailableTailors();
    if (tailors.isNotEmpty) {
      _selectedTailorId = tailors.first.id;
    }

    // Set default date to tomorrow
    _selectedDate = DateTime.now().add(const Duration(days: 1));

    // Set default time slot
    _selectedTimeSlot = '10:00 AM - 1:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.product.name, style: TextStyle(color: primaryBrown)),
        actions: [
          GestureDetector(
            onTap: () {
              DataService().toggleFavorite(widget.product.id);
              setState(() {});
            },
            child: Icon(
              widget.product.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.product.isFavorite ? Colors.red : primaryBrown,
            ),
          ),
          const SizedBox(width: 15),
          Stack(
            children: [
              Icon(Icons.shopping_bag_outlined, color: primaryBrown),
              Positioned(
                  right: 0,
                  child: CircleAvatar(
                      radius: 7,
                      backgroundColor: primaryBrown,
                      child: Text("$_quantity",
                          style: TextStyle(fontSize: 8, color: Colors.white)))),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selected Item Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(widget.product.image,
                          width: 60, height: 60, fit: BoxFit.cover)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.product.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryBrown)),
                              Text(DummyData.formatPrice(widget.product.price),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryBrown))
                            ]),
                        Text("Size: $_selectedSize",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.local_shipping,
                              size: 14, color: primaryBrown),
                          const SizedBox(width: 4),
                          Text(
                              "Delivery in ${widget.product.deliveryDays} Days",
                              style: TextStyle(fontSize: 11))
                        ]),
                      ])),
                  TextButton(
                      onPressed: () {},
                      child:
                          Text("Edit", style: TextStyle(color: primaryBrown))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("Add to Request",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                  "One of our partner tailors will collect your measurements...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            const SizedBox(height: 24),

            // Size Selection
            _buildSizeSelection(),
            const SizedBox(height: 24),

            // Quantity Selection
            _buildQuantitySelection(),
            const SizedBox(height: 24),

            // Address Selection
            _buildAddressSelection(),
            const SizedBox(height: 24),

            // Special Instructions
            _buildSpecialInstructions(),
            const SizedBox(height: 24),

            // Custom Tab Switcher
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isStoreSelection = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: _isStoreSelection
                                ? accentBrown
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Text("Select Store",
                                style: TextStyle(
                                  color: _isStoreSelection
                                      ? Colors.white
                                      : primaryBrown,
                                  fontWeight: _isStoreSelection
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isStoreSelection = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: !_isStoreSelection
                                ? accentBrown
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Text("Schedule Pickup",
                                style: TextStyle(
                                  color: !_isStoreSelection
                                      ? Colors.white
                                      : primaryBrown,
                                  fontWeight: !_isStoreSelection
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic content based on selection
            if (_isStoreSelection) ...[
              _buildStoreSelection(),
              const SizedBox(height: 16),
            ] else ...[
              _buildSchedulePickup(),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 20),
            const Row(children: [
              Expanded(child: Divider()),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("OR")),
              Expanded(child: Divider())
            ]),
            const SizedBox(height: 20),
            _buildAddressInput(),
          ],
        ),
      ),
      bottomNavigationBar: _buildTotalFooter(context, "Finalize Request →"),
    );
  }

  Widget _buildStoreSelection() {
    final dataService = DataService();
    final tailors = dataService.getAvailableTailors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Tailor Store",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        const SizedBox(height: 8),
        ...tailors.map((tailor) {
          final isSelected = tailor.id == _selectedTailorId;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTailorId = tailor.id;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? accentBrown.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accentBrown : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      tailor.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tailor.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? accentBrown : primaryBrown,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: tailor.isAvailable
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tailor.isAvailable ? 'Available' : 'Busy',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(
                              ' ${tailor.rating}',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryBrown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${tailor.reviewCount} reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tailor.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? accentBrown : Colors.grey,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSchedulePickup() {
    final timeSlots = [
      '9:00 AM - 12:00 PM',
      '12:00 PM - 3:00 PM',
      '3:00 PM - 6:00 PM',
      '6:00 PM - 9:00 PM',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Schedule Pickup",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        const SizedBox(height: 8),

        // Date Selection
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Date",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                  )),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: accentBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: accentBrown),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select Date',
                      style: TextStyle(
                        color: primaryBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ??
                              DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Icon(Icons.edit, color: accentBrown),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Time Slot Selection
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Time Slot",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                  )),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((timeSlot) {
                  final isSelected = timeSlot == _selectedTimeSlot;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = timeSlot;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? accentBrown : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        timeSlot,
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryBrown,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Provide Delivery Address",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: "Enter your address here",
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(Icons.home, color: accentBrown),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        )
      ],
    );
  }

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Size",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.product.sizes.map((size) {
            final isSelected = size == _selectedSize;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? accentBrown : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? Colors.white : primaryBrown,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quantity",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_quantity > 1) {
                  setState(() {
                    _quantity--;
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(Icons.remove, color: primaryBrown),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              _quantity.toString(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _quantity++;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(Icons.add, color: primaryBrown),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSelection() {
    final user = DataService().getCurrentUser();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Delivery Address",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        const SizedBox(height: 8),
        ...user.savedAddresses.map((address) {
          final isSelected = address == _selectedAddress;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAddress = address;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? accentBrown.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? accentBrown : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? accentBrown : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        color: isSelected ? accentBrown : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        GestureDetector(
          onTap: () {
            // Add new address logic
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: accentBrown),
                const SizedBox(width: 12),
                Text(
                  "Add New Address",
                  style: TextStyle(
                      color: accentBrown, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Special Instructions (Optional)",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          onChanged: (value) {
            _specialInstructions = value;
          },
          decoration: InputDecoration(
            hintText: "Any special requirements or measurements...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBrown),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalFooter(BuildContext context, String buttonText) {
    final totalPrice = widget.product.price * _quantity;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              product: widget.product,
              selectedSize: _selectedSize,
              quantity: _quantity,
              deliveryAddress: _selectedAddress,
              specialInstructions: _specialInstructions,
              selectedTailorId: _selectedTailorId,
              selectedDate: _selectedDate,
              selectedTimeSlot: _selectedTimeSlot,
              isStoreSelection: _isStoreSelection,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:",
                    style: TextStyle(color: accentBrown, fontSize: 18)),
                Text(DummyData.formatPrice(totalPrice),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: primaryBrown)),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: accentBrown,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(buttonText,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
