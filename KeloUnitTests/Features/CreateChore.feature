Feature: Create Chore

  @CreateChore
  Scenario Outline: Valid Length 1
    Given the user that enters a chore "<name>"
    When the user validates the chore name
    Then the chore name length must be less or equal than 32
    Examples:
      | name                                       |
      | Recoger la habitación                      |
      | Lavar los platos y la cocina hoy           |

  @CreateChore
  Scenario Outline: Valid Length 2
    Given the user that enters a chore "<name>"
    When the user validates the chore name
    Then the chore name length must be greater or equal than 5
    Examples:
      | name                                       |
      | Lavar coche                                |
      | Lavar                                      |

  @CreateChore
  Scenario Outline: Invalid Length 1
    Given the user that enters a chore "<name>"
    When the user validates the chore name
    Then the chore name length must not be greater than 32
    Examples:
      | name                                            |
      | Ir a por el coche al taller y luego a la compra |
      | Lavar los platos y la cocina para ayer          |

  @CreateChore
  Scenario Outline: Invalid Length 2
    Given the user that enters a chore "<name>"
    When the user validates the chore name
    Then the chore name length must not be less than 5
    Examples:
      | name |
      | Casa |
      | Yo   |

  @CreateChore
  Scenario Outline: Emptiness
    Given the user that enters a chore "<name>"
    When the user validates the chore name
    Then the chore name must not be empty
    Examples:
      | name              |
      |      \0           |

  @CreateChore
  Scenario Outline: Valid Characters
    Given the user that enters a chore "<name>"
    When the user validates the chore name
    Then the chore name must only contain alphanumerical characters with spaces
    Examples:
      | name                             |
      | Limpiar coche a las 8 PM         |
      | Avisar a César Núñez             |

  @CreateChore
  Scenario Outline: Invalid Characters
    Given the user that enters a chore "<name>"
    When the user validates the chore name
    Then the chore name must not contain special characters
    Examples:
      | name                 |
      | *o* Lavar Ropa *o*   |
      | /$$ Planchar $$/     |
