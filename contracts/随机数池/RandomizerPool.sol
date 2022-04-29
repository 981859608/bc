// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// 从数字池中随机取出一个数
// 同一个池子，每个数字只能被取出一次
contract RandomizerPool {
    // 池子总数，决定随机数取值范围，[1, 10000]
    uint32 constant private totalCount = 10000;
    // 记录已取数量
    uint32 private alreadyPopCount;
    // 池子
    // uint[totalCount] public pool;
    mapping(uint => uint) public pool;

    // 测试日志
    event LogStep(uint value);

    /**
     * 根据随机盐值，随机取出池子中数字
     * salt: 盐值
     * returns uint: 随机取出的数字
     */
    function generateRandomId(uint salt) external returns(uint randomId) {
        // 已取出数要小于总数
        require(alreadyPopCount < totalCount, "already generate done");
        // 根据各种“随机值”生成hash值
        uint rand = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.number, salt, alreadyPopCount)));
        randomId = getIndex(rand) + 1;
        emit LogStep(randomId); // 方便测试
    }

    /**
     * 根据随机值从池子中取值
     */
    function getIndex(uint rand) internal returns (uint) {
        // 取剩下数组长度余数
        uint lastCount = totalCount - alreadyPopCount;
        uint index = rand % lastCount;
        // 该下标对应的值若 >0 则取真实下标对应的值
        uint target = pool[index];
        uint pointIndex = target > 0 ? target : index;
        // 获取最后一个元素
        target = pool[--lastCount];
        // 将index指向没有抽出去过的地址
        pool[index] = target > 0 ? target : lastCount;
        // 更新已取出数量
        alreadyPopCount++;
        return pointIndex;
    }
}