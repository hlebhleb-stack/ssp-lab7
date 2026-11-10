// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract LectureCoursesRegistry {

    // ============================================================
    // DATA STRUCTURES
    // ============================================================

    struct Course {
        string  courseName;
        string  lecturer;
        uint256 semester;
        string  department;
        bool    hasCourseProject;
        bool    hasExam;
        bool    isActive;
    }

    // ============================================================
    // STATE VARIABLES
    // ============================================================

    address public admin;
    string  public registryName;
    uint256 public courseCount;

    mapping(uint256 => Course) public courses;

    // ============================================================
    // EVENTS
    // ============================================================

    event CourseAdded(uint256 indexed courseId, string courseName);
    event CourseUpdated(uint256 indexed courseId, string courseName);
    event CourseDeleted(uint256 indexed courseId);

    // ============================================================
    // MODIFIERS
    // ============================================================

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    modifier courseExists(uint256 _courseId) {
        require(courses[_courseId].isActive, "Course does not exist");
        _;
    }

    // ============================================================
    // CONSTRUCTOR
    // ============================================================

    constructor(string memory _registryName) {
        admin        = msg.sender;
        registryName = _registryName;
        courseCount  = 0;
    }

    // ============================================================
    // CORE FUNCTIONS
    // ============================================================

    function addCourse(
        string  memory _courseName,
        string  memory _lecturer,
        uint256        _semester,
        string  memory _department,
        bool           _hasCourseProject,
        bool           _hasExam
    ) public onlyAdmin {
        require(bytes(_courseName).length  > 0, "Course name cannot be empty");
        require(bytes(_lecturer).length    > 0, "Lecturer cannot be empty");
        require(_semester > 0 && _semester < 20, "Invalid semester");
        require(bytes(_department).length  > 0, "Department cannot be empty");

        courseCount++;
        courses[courseCount] = Course({
            courseName      : _courseName,
            lecturer        : _lecturer,
            semester        : _semester,
            department      : _department,
            hasCourseProject: _hasCourseProject,
            hasExam         : _hasExam,
            isActive        : true
        });

        emit CourseAdded(courseCount, _courseName);
    }

    function updateCourse(
        uint256        _courseId,
        string  memory _newCourseName,
        string  memory _newLecturer,
        uint256        _newSemester,
        string  memory _newDepartment,
        bool           _newHasCourseProject,
        bool           _newHasExam
    ) public onlyAdmin courseExists(_courseId) {
        require(bytes(_newCourseName).length > 0, "Course name cannot be empty");
        require(bytes(_newLecturer).length   > 0, "Lecturer cannot be empty");
        require(_newSemester > 0 && _newSemester < 20, "Invalid semester");
        require(bytes(_newDepartment).length > 0, "Department cannot be empty");

        courses[_courseId].courseName       = _newCourseName;
        courses[_courseId].lecturer         = _newLecturer;
        courses[_courseId].semester         = _newSemester;
        courses[_courseId].department       = _newDepartment;
        courses[_courseId].hasCourseProject = _newHasCourseProject;
        courses[_courseId].hasExam          = _newHasExam;

        emit CourseUpdated(_courseId, _newCourseName);
    }

    function deleteCourse(uint256 _courseId) public onlyAdmin courseExists(_courseId) {
        courses[_courseId].isActive = false;
        emit CourseDeleted(_courseId);
    }

    // ============================================================
    // VIEW FUNCTIONS (READ ONLY)
    // ============================================================

    function getCourse(uint256 _courseId)
        public
        view
        courseExists(_courseId)
        returns (
            string memory,
            string memory,
            uint256,
            string memory,
            bool,
            bool
        )
    {
        Course memory c = courses[_courseId];
        return (
            c.courseName,
            c.lecturer,
            c.semester,
            c.department,
            c.hasCourseProject,
            c.hasExam
        );
    }

    function getAllCourses()
        public
        view
        returns (
            uint256[] memory,
            string[]  memory,
            string[]  memory,
            uint256[] memory,
            string[]  memory,
            bool[]    memory,
            bool[]    memory
        )
    {
        uint256 activeCount = 0;
        for (uint256 i = 1; i <= courseCount; i++) {
            if (courses[i].isActive) {
                activeCount++;
            }
        }

        uint256[] memory ids              = new uint256[](activeCount);
        string[]  memory names            = new string[](activeCount);
        string[]  memory lecturers        = new string[](activeCount);
        uint256[] memory semesters        = new uint256[](activeCount);
        string[]  memory departments      = new string[](activeCount);
        bool[]    memory courseProjects   = new bool[](activeCount);
        bool[]    memory exams            = new bool[](activeCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= courseCount; i++) {
            if (courses[i].isActive) {
                ids[index]            = i;
                names[index]          = courses[i].courseName;
                lecturers[index]      = courses[i].lecturer;
                semesters[index]      = courses[i].semester;
                departments[index]    = courses[i].department;
                courseProjects[index] = courses[i].hasCourseProject;
                exams[index]          = courses[i].hasExam;
                index++;
            }
        }

        return (ids, names, lecturers, semesters, departments, courseProjects, exams);
    }

    function getCourseCount() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= courseCount; i++) {
            if (courses[i].isActive) {
                count++;
            }
        }
        return count;
    }

    // ============================================================
    // ADMIN FUNCTIONS
    // ============================================================

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }

    function setRegistryName(string memory _newName) public onlyAdmin {
        require(bytes(_newName).length > 0, "Name cannot be empty");
        registryName = _newName;
    }
}
