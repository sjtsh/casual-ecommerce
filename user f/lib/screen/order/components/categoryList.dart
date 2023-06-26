import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';
import 'package:ezdeliver/screen/products/components/subcategorybox.dart';

class CategoryListDisplay extends ConsumerWidget {
  const CategoryListDisplay({Key? key, required this.subCategories})
      : super(key: key);

  final List<SubCategory> subCategories;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSubCategory =
        ref.watch(productCategoryServiceProvider).selectedSubCategory;

    return GridView.builder(
        padding: EdgeInsets.only(top: 22.sh()),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: ResponsiveLayout.isMobile
                ? 0.9
                : ResponsiveLayout.isDesktop
                    ? 5
                    : 2),
        itemCount: subCategories.isEmpty ? 4 : subCategories.length,
        itemBuilder: (context, index) {
          final isSelected = subCategories.isEmpty
              ? false
              : selectedSubCategory?.id == subCategories[index].id;
          return SubCategoryBox(
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(productCategoryServiceProvider)
                    .selectSubCategory(subCategories[index]);
              },
              loading: subCategories.isEmpty,
              subCategory: subCategories.isEmpty ? null : subCategories[index]);
        });
  }
}
