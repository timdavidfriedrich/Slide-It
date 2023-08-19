import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/core/services/data/cloud_data_service.dart';
import 'package:rating/features/core/services/data/storage_data_service.dart';

class DataService {
  static DataService instance = DataService();

  final DataProvider _dataProvider = Provider.of<DataProvider>(Global.context, listen: false);
  final CloudService _cloudService = CloudService.instance;
  final StorageService _storageService = StorageService.instance;
}
