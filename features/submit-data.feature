@temp-dir
Feature: Submit data from provided input

  Background:

    Given a file "default.config":
      """
      <hq-grapher-icinga-perfdata-config>

        <daemon host="dhost" port="dport"/>

        <mapping name="graph1" host="host1" service="service1">
          <value name="data1"/>
        </mapping>

        <mapping name="graph2" host="host2" service="service2">
          <value name="data2"/>
        </mapping>

        <mapping name="graph3" host="host3" service="service3">
          <value name="data3"/>
          <value name="data4"/>
        </mapping>

        <mapping name="graph4" host="host4" service="service4">
          <value name="data 5"/>
        </mapping>

        <mapping name="graph5" host="host5" service="service5">
          <value name="data'6"/>
        </mapping>

      </hq-grapher-icinga-perfdata-config>
      """

    And a file "default.args":
      """
      --config default.config
      input.data
      """

  Scenario: Basic example

    Given a file "input.data":
      """
      10,host1,service1,data1=20
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph1.rrd 10:20
      """

    And the command exit status should be 0

  Scenario: No lines

    Given a file "input.data":
      """
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      """

    And the command exit status should be 0

  Scenario: Multiple lines

    Given a file "input.data":
      """
      10,host1,service1,data1=20
      30,host2,service2,data2=40
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph1.rrd 10:20
      --daemon dhost:dport graph2.rrd 30:40
      """

    And the command exit status should be 0

  Scenario: Multiple data points

    Given a file "input.data":
      """
      10,host3,service3,data3=20 data4=30
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph3.rrd 10:20:30
      """

    And the command exit status should be 0

  Scenario: Extra information

    Given a file "input.data":
      """
      10,host1,service1,data1=20units;30;40;50;60
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph1.rrd 10:20
      """

    And the command exit status should be 0

  Scenario: Space in data name

    Given a file "input.data":
      """
      10,host4,service4,'data 5'=20
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph4.rrd 10:20
      """

    And the command exit status should be 0

  Scenario: Apostrophe in data name

    Given a file "input.data":
      """
      10,host5,service5,'data''6'=20
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph5.rrd 10:20
      """

    And the command exit status should be 0

  Scenario: Missing value

    Given a file "input.data":
      """
      10,host3,service3,data4=30
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph3.rrd 10:U:30
      """

    And the command exit status should be 0

  Scenario: No values

    Given a file "input.data":
      """
      10,host1,service1,
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph1.rrd 10:U
      """

    And the command exit status should be 0
