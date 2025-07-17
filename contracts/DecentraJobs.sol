// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DecentraJobs {
    enum JobStatus { Open, InProgress, Completed, Cancelled }

    struct Job {
        address client;
        string description;
        uint256 reward;
        JobStatus status;
        address freelancer;
    }

    uint256 public jobCount;
    mapping(uint256 => Job) public jobs;

    event JobPosted(uint256 jobId, address client, uint256 reward);
    event JobAccepted(uint256 jobId, address freelancer);
    event JobCompleted(uint256 jobId);
    event JobCancelled(uint256 jobId);

    function postJob(string memory description) public payable {
        require(msg.value > 0, "Reward must be > 0");

        jobs[jobCount] = Job({
            client: msg.sender,
            description: description,
            reward: msg.value,
            status: JobStatus.Open,
            freelancer: address(0)
        });

        emit JobPosted(jobCount, msg.sender, msg.value);
        jobCount++;
    }

    function acceptJob(uint256 jobId) public {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Open, "Job not open");

        job.freelancer = msg.sender;
        job.status = JobStatus.InProgress;

        emit JobAccepted(jobId, msg.sender);
    }

    function completeJob(uint256 jobId) public {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Only client can confirm");
        require(job.status == JobStatus.InProgress, "Job not in progress");

        job.status = JobStatus.Completed;
        payable(job.freelancer).transfer(job.reward);

        emit JobCompleted(jobId);
    }

    function cancelJob(uint256 jobId) public {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Only client can cancel");
        require(job.status == JobStatus.Open, "Job cannot be cancelled");

        job.status = JobStatus.Cancelled;
        payable(job.client).transfer(job.reward);

        emit JobCancelled(jobId);
    }

    function getJobDetails(uint256 jobId) public view returns (
        address client,
        string memory description,
        uint256 reward,
        JobStatus status,
        address freelancer
    ) {
        Job storage job = jobs[jobId];
        return (
            job.client,
            job.description,
            job.reward,
            job.status,
            job.freelancer
        );
    }
}
