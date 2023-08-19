import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/cloud_service.dart';
import 'package:rating/features/core/services/storage_service.dart';

class DataService {
  static DataService instance = DataService();

  final DataProvider _dataProvider = Provider.of<DataProvider>(Global.context, listen: false);
  final CloudService _cloudService = CloudService.instance;
  final StorageService _storageService = StorageService.instance;
}
