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
      20,host1,service1,data1 = 20
      30,host1,service1,data1=20
      """

    When I invoke hq-grapher-icinga-perfdata with "default.args"

    Then it should submit the following data:
      """
      --daemon dhost:dport graph1.rrd 10:20
      --daemon dhost:dport graph1.rrd 30:20
      """

    And the command stderr should be:
      """
      Ignoring invalid data on line 2: 20,host1,service1,data1 = 20
      """

    And the command exit status should be 10

# vim: et ts=2
