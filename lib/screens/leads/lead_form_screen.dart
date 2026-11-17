import 'package:flutter/material.dart';
import '../../models/lead.dart';

import '../../services/lead_service.dart';

import '../../services/permission_manager.dart';
class LeadFormScreen extends StatefulWidget {
  final Lead? lead;

  const LeadFormScreen({
    super.key,
    this.lead,
  });

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final companyController = TextEditingController();
  final titleController = TextEditingController();

  final businessPhoneController = TextEditingController();
  final mobilePhoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();

  final streetController = TextEditingController();
  final suburbController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();

  final descriptionController = TextEditingController();

  bool saving = false;
  @override
void initState() {
  super.initState();

  if (widget.lead != null) {
    firstNameController.text = widget.lead!.firstName;
    lastNameController.text = widget.lead!.lastName;
    companyController.text = widget.lead!.accountName;
    titleController.text = widget.lead!.title;

    businessPhoneController.text = widget.lead!.phoneWork;
    mobilePhoneController.text = widget.lead!.phoneMobile;

    emailController.text = widget.lead!.email;
    websiteController.text = widget.lead!.website;

    streetController.text = widget.lead!.street;
    suburbController.text = widget.lead!.suburb;
    cityController.text = widget.lead!.city;
    provinceController.text = widget.lead!.province;
    postalCodeController.text = widget.lead!.postalCode;
    countryController.text = widget.lead!.country;

    descriptionController.text = widget.lead!.description;
  }
}

  Future<void> saveLead() async {
    final allowed = widget.lead == null
        ? PermissionManager.canCreate('Leads')
        : PermissionManager.canEdit('Leads');

    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to save this lead.'),
        ),
      );
      return;
    }
  if (lastNameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Last Name is required."),
      ),
    );
    return;
  }

  setState(() {
    saving = true;
  });

  final lead = Lead(
    id: widget.lead?.id ?? "",
    firstName: firstNameController.text.trim(),
    lastName: lastNameController.text.trim(),
    accountName: companyController.text.trim(),
    title: titleController.text.trim(),
    phoneWork: businessPhoneController.text.trim(),
    phoneMobile: mobilePhoneController.text.trim(),
    email: emailController.text.trim(),
    website: websiteController.text.trim(),
    street: streetController.text.trim(),
    suburb: suburbController.text.trim(),
    city: cityController.text.trim(),
    province: provinceController.text.trim(),
    postalCode: postalCodeController.text.trim(),
    country: countryController.text.trim(),
    description: descriptionController.text.trim(),
    status: widget.lead?.status ?? "New",
    leadSource: widget.lead?.leadSource ?? "",
    assignedTo: widget.lead?.assignedTo ?? "",
    dateCreated: widget.lead?.dateCreated ?? "",
  );

  final success = widget.lead == null
      ? await LeadService().createLead(lead)
      : await LeadService().updateLead(lead);

  if (!mounted) return;

  setState(() {
    saving = false;
  });

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.lead == null
              ? "Lead created successfully."
              : "Lead updated successfully.",
        ),
      ),
    );

    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.lead == null
              ? "Failed to create lead."
              : "Failed to update lead.",
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Text(
  widget.lead == null
      ? "New Lead"
      : "Edit Lead",
),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "General Information",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: firstNameController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "First Name",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: lastNameController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Last Name *",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: companyController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Company",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: titleController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Job Title",
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Contact Information",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: businessPhoneController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Business Phone",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: mobilePhoneController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile Phone",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: websiteController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: "Website",
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Address",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: streetController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Street",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: suburbController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Suburb",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: cityController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "City",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: provinceController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Province / State",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: postalCodeController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Postal Code",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: countryController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: "Country",
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Additional Information",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Description",
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                 saving
    ? "Saving..."
    : widget.lead == null
        ? "CREATE LEAD"
        : "UPDATE LEAD",
                ),
                onPressed: saving ? null : saveLead,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
