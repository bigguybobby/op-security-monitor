// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecurityRegistry
/// @notice On-chain registry of security scores and audit reports for OP contracts
contract SecurityRegistry {
    struct AuditReport {
        address auditor;
        uint8 score; // 0-100
        string ipfsHash; // full report on IPFS
        uint256 timestamp;
    }

    mapping(address => AuditReport[]) public reports;
    mapping(address => bool) public verifiedAuditors;
    address public owner;

    event AuditSubmitted(address indexed contract_, address indexed auditor, uint8 score);
    event AuditorVerified(address indexed auditor);

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    constructor() { owner = msg.sender; }

    function verifyAuditor(address auditor) external onlyOwner {
        verifiedAuditors[auditor] = true;
        emit AuditorVerified(auditor);
    }

    function submitAudit(address contract_, uint8 score, string calldata ipfsHash) external {
        require(verifiedAuditors[msg.sender], "not verified auditor");
        require(score <= 100, "invalid score");
        reports[contract_].push(AuditReport(msg.sender, score, ipfsHash, block.timestamp));
        emit AuditSubmitted(contract_, msg.sender, score);
    }

    function getLatestScore(address contract_) external view returns (uint8) {
        uint256 len = reports[contract_].length;
        if (len == 0) return 0;
        return reports[contract_][len - 1].score;
    }

    function getReportCount(address contract_) external view returns (uint256) {
        return reports[contract_].length;
    }
}
