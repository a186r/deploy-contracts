pragma solidity >=0.4.21 <0.7.0;

import "./Storage.sol";

 contract StorageFactory {

    string constant PERMISSIONDENIED_APPMANAGER_FACTORY = "50001"; // 权限错误，操作人不是联盟管理者
    string constant PERMISSIONDENIED_APPOWNER = "50002"; // 权限错误，操作人不是合约部署者
    string constant PLATFORM_CREATED = "50006"; // 平台已创建过存证实体合约(平台已开户)

	address public appOwner;//合约部署者
	mapping(address => bool) public isAppManager;//联盟管理者
	mapping(bytes32 => bool) public platformCreated;// 平台是否创建过存证实体合约

    ///@notice 初始化存储实体合约
	event InitStorage(
        address indexed factoryAddress,
        address storageInstanceAddress
    );

	///@notice 修改联盟管理者权限
	event AppManagersStatusChanged(
		address indexed factoryAddress,
		address appManagerAddress,
		bool status
	);

    constructor () public {
		appOwner = msg.sender;
    }

	modifier onlyAppOwner() {
		require(msg.sender == appOwner, PERMISSIONDENIED_APPOWNER);
		_;
	}

	modifier onlyAppManager() {
		require(isAppManager[msg.sender], PERMISSIONDENIED_APPMANAGER_FACTORY);
		_;
	}

	///@notice 初始化存储实体合约
	///@param _platformOperator 平台操作员地址
	function initStorage(address _platformOperator, string memory _systemId) public onlyAppManager {
		require(!platformCreated[keccak256(abi.encode(_systemId))], PLATFORM_CREATED);
		Storage storageInstance = new Storage(_platformOperator, address(this), _systemId);
		platformCreated[keccak256(abi.encode(_systemId))] = true;
        emit InitStorage(address(this), address(storageInstance));
	}

	///@notice 修改联盟管理者权限
	///@param _appManager 联盟管理者地址
	///@param _status 权限状态
	function setAppManager(address _appManager, bool _status) public onlyAppOwner {
		isAppManager[_appManager] = _status;
		emit AppManagersStatusChanged(address(this), _appManager, _status);
	}
 }