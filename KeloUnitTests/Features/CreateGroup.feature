Feature: Create Group

  @CreateGroup
  Scenario Outline: Valid Length 1
    Given the user that enters its group name "<name>"
    When the user validates its group name
    Then the group name length must be less or equal than 32
    Examples:
      | name                                       |
      | Casita de Verano                           |
      | Casa Rural de Verano 2021 Madrid           |

  @CreateGroup
  Scenario Outline: Valid Length 2
    Given the user that enters its group name "<name>"
    When the user validates its group name
    Then the group name length must be greater or equal than 5
    Examples:
      | name                                       |
      | La Casa del Ron                            |
      | Casas                                      |

  @CreateGroup
  Scenario Outline: Invalid Length 1
    Given the user that enters its group name "<name>"
    When the user validates its group name
    Then the group name length must not be greater than 32
    Examples:
      | name                                         |
      | Casa Rural de Verano 2021 Madrid Badajoz     |
      | Verano 2022 Free Corona House Indoor         |

  @CreateGroup
  Scenario Outline: Invalid Length 2
    Given the user that enters its group name "<name>"
    When the user validates its group name
    Then the group name length must not be less than 5
    Examples:
      | name |
      | Casa |
      | C2   |

  @CreateGroup
  Scenario Outline: Emptiness
    Given the user that enters its group name "<name>"
    When the user validates its group name
    Then the group name must not be empty
    Examples:
      | name              |
      | \0                |

  @CreateGroup
  Scenario Outline: Valid Characters
    Given the user that enters its group name "<name>"
    When the user validates its group name
    Then the group name must only contain alphanumerical characters with spaces
    Examples:
      | name |
      | Casa Rural de Verano 2021 Madrid |
      | 2022 Verano Guipúzcua            |
      | Casa Pueblo Capóeira Barça       |
      | Écija 2022 Verano                |

  @CreateGroup
  Scenario Outline: Invalid Characters
    Given the user that enters its group name "<name>"
    When the user validates its group name
    Then the group name must not contain special characters
    Examples:
      | name                            |
      | *o* Casita Rural *o*            |
      | /$$ La mejor CASA de todas $$/  |
