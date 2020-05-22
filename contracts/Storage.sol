pragma solidity >=0.4.21 <0.7.0;

contract Storage{

    string constant PERMISSIONDENIED_OPERATOR = "50003"; // 权限错误，操作人不是平台操作员
    string constant PERMISSIONDENIED_APPMANAGER = "50004"; // 权限错误，操作人不是联盟管理者
    string constant EMPRYSTRING = "50005"; // 请求参数为空
    string constant WRONG_SYSTEMID = "50007"; // systemId不匹配
    string constant STORAGE_PAUSED = "50008"; // 存证合约已经暂停

    ///@notice 存储数据
    event StoreData(
        address indexed factoryAddress,
        address indexed storageInstanceAddress,
        string systemId,
        string assetsType,
        string tokenId,
        string data
    );

    ///@notice 获取存储的数据
    event GotData(string data);

    ///@notice 修改操作员权限
    event OperatorStatusChanged(
        address indexed factoryAddress,
        address indexed storageInstanceAddress,
        address operatorAddress,
        bool status
    );

    mapping(address => bool) public isOperator;
    mapping(bytes32 => string) datas;
    mapping(address => bool) public appManagers;
    address public factoryAddress;
    string public systemId;
    bool public pause;

    constructor(address _platformOperator, address _factoryAddress, string memory _systemId) public {
        isOperator[_platformOperator] = true;
        appManagers[tx.origin] = true;
        factoryAddress = _factoryAddress;
        systemId = _systemId;
    }

    modifier onlyOperator() {
        require(isOperator[msg.sender], PERMISSIONDENIED_OPERATOR);
        _;
    }

    modifier onlyAppManager() {
        require(appManagers[msg.sender], PERMISSIONDENIED_APPMANAGER);
        _;
    }

    ///@notice 存储数据
    ///@param _systemId 系统编号
    ///@param _assetsType 资产类型
    ///@param _tokenId TokenID
    ///@param _data 要存储的数据
    function storeData(string memory _systemId, string memory _assetsType, string memory _tokenId, string memory _data) public onlyOperator {
        require(!pause, STORAGE_PAUSED);
        require(notEmptyString(_systemId, _assetsType, _tokenId), EMPRYSTRING);
        require(keccak256(abi.encode(systemId)) == keccak256(abi.encode(_systemId)), WRONG_SYSTEMID);
        datas[keccak256(abi.encodePacked(_systemId, _assetsType, _tokenId))] = string(
            abi.encodePacked(datas[keccak256(abi.encodePacked(_systemId, _assetsType, _tokenId))], _data, ",")
        );
        emit StoreData(factoryAddress, address(this), _systemId, _assetsType, _tokenId, _data);
    }

    ///@notice 查询数据
    ///@param _systemId 系统编号
    ///@param _assetsType 资产类型
    ///@param _tokenId TokenID
    function getData(string memory _systemId, string memory _assetsType, string memory _tokenId) public {
        require(keccak256(abi.encode(systemId)) == keccak256(abi.encode(_systemId)), WRONG_SYSTEMID);
        emit GotData(datas[keccak256(abi.encodePacked(_systemId, _assetsType, _tokenId))]);
    }

    ///@notice 联盟管理者管理平台操作员
    ///@param _operator 操作员地址
    ///@param _status true-设置为平台操作员 false-撤销平台操作员权限
    function changeAdminStatus(address _operator, bool _status) public onlyAppManager {
        isOperator[_operator] = _status;
        emit OperatorStatusChanged(factoryAddress, address(this), _operator, _status);
    }

    ///@notice 判断字符串是否为空
    function notEmptyString(string memory a, string memory b, string memory c) internal pure returns (bool) {
        bytes memory tempEmptyStringA = bytes(a);
        bytes memory tempEmptyStringB = bytes(b);
        bytes memory tempEmptyStringC = bytes(c);

        if(tempEmptyStringA.length != 0 && tempEmptyStringB.length != 0 && tempEmptyStringC.length != 0) {
            return true;
        }else{
            return false;
        }
    }

    ///@notice 暂停或启用存储合约 true-暂停 false-启用 默认启用
    function pauseStorage(bool _pause) public onlyAppManager {
        pause = _pause;
    }
}