import 'package:ezdeliver/screen/component/helper/exporter.dart';


class LocationWidget extends StatelessWidget {
  const LocationWidget({
    Key? key,
    required this.icon,
    required this.header,
    required this.onTap,
    this.body,
    this.address,
    required this.show,
  }) : super(key: key);
  final IconData icon;
  final String header;
  final String? body;
  final Function? onTap;
  final String? address;
  final bool show;
  @override
  Widget build(BuildContext context) {
    // print(show);
    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sw(), vertical: 10.sh()),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.sr()),
            border: show && address != null
                ? Border.all(
                    color: Theme.of(context).primaryColor,
                  )
                : null,
            color: Theme.of(context).primaryColor.withOpacity(0.10)),
        // height: 44.sh(),
        width: double.infinity,
        child: Row(
          children: [
            Container(
                color: Theme.of(context).primaryColor,
                child: Icon(
                  icon,
                  color: CustomTheme.whiteColor,
                )),
            SizedBox(
              width: 16.sw(),
            ),
            Expanded(
              child: Text(header,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: CustomTheme.getBlackColor(),
                      )),
            ),
            if (address != null && show)
              Expanded(
                child: Text(address!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: CustomTheme.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
