<?php
/*
 * Copyright 2005-2014 MERETHIS
 * Centreon is developped by : Julien Mathis and Romain Le Merlus under
 * GPL Licence 2.0.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation ; either version 2 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, see <http://www.gnu.org/licenses>.
 *
 * Linking this program statically or dynamically with other modules is making a
 * combined work based on this program. Thus, the terms and conditions of the GNU
 * General Public License cover the whole combination.
 *
 * As a special exception, the copyright holders of this program give MERETHIS
 * permission to link this program with independent modules to produce an executable,
 * regardless of the license terms of these independent modules, and to copy and
 * distribute the resulting executable under terms of MERETHIS choice, provided that
 * MERETHIS also meet, for each linked independent module, the terms  and conditions
 * of the license of that module. An independent module is a module which is not
 * derived from this program. If you modify this program, you may extend this
 * exception to your version of the program, but you are not obliged to do so. If you
 * do not wish to do so, delete this exception statement from your version.
 *
 * For more information : contact@centreon.com
 *
 *
 */

namespace CentreonPerformance\Repository\Graph;

/**
 * Class for generate values for graph service
 *
 * @author Maximilien Bersoult <mbersoult@merethis.com>
 * @version 3.0.0
 * @package Centreon
 */
class Service extends \CentreonPerformance\Repository\Graph
{
    /**
     * Constructor
     *
     * @param int $serviceId The service ID
     * @param int $startTime The start time for graph
     * @param int $endTime The end time for graph
     */
    public function __construct($serviceId, $startTime, $endTime)
    {
        $di = \Centreon\Internal\Di::getDefault();
        $dbconn = $di->get('db_centreon');

        /* Get the list of metrics */
        $query = "SELECT i.id, i.service_description, m.metric_id, m.metric_name, m.unit_name, m.warn, m.warn_low, m.crit, m.crit_low, m.min, m.max
            FROM rt_index_data i, rt_metrics m
            WHERE i.service_id = :service_id
                AND i.id = m.index_id
                AND m.hidden = '0'";
        $stmt = $dbconn->prepare($query);
        $stmt->bindParam(':service_id', $serviceId);
        $stmt->execute();

        while ($row = $stmt->fetch()) {
            $this->metrics[] = array(
                'id' => $row['metric_id'],
                'unit' => $row['unit_name'],
                'color' => null,
                'legend' => $row['metric_name'],
                'graph_type' => 'line'
            );
        }

        parent::__construct($startTime, $endTime);
    }
}
