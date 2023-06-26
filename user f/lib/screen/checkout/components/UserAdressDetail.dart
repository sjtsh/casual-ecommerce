import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/others/validator.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

class UserAddressDetailForm extends ConsumerWidget {
  const UserAddressDetailForm(
      {required this.address, required this.formKey, super.key});
  final AddressModel address;
  final GlobalKey<FormState> formKey;
  @override
  Widget build(BuildContext context, ref) {
    final cartService = ref.watch(cartServiceProvider);
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(
            height: 12.sh(),
          ),
          InputTextField(
            title: "Full Name*",
            isVisible: true,
            onChanged: (val) {
              if (cartService.selectedDeliveryAddress.value != null) {
                ref.read(cartServiceProvider).selectedDeliveryAddress.value =
                    cartService.selectedDeliveryAddress.value!
                        .copyWith(fullName: val);
              }
            },
            validator: (val) => validateName(val!),
            value: address.fullName,
          ),
          SizedBox(
            height: 18.sh(),
          ),
          InputTextField(
            title: "Mobile number*",
            isVisible: true,
            isdigits: true,
            onChanged: (val) {
              if (cartService.selectedDeliveryAddress.value != null) {
                ref.read(cartServiceProvider).selectedDeliveryAddress.value =
                    cartService.selectedDeliveryAddress.value!
                        .copyWith(phone: val);
              }
            },
            validator: (val) => validatePhone(val!),
            value: address.phone,
          ),
          SizedBox(
            height: 10.sh(),
          ),
        ],
      ),
    );
  }
}
