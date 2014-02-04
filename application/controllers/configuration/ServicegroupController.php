<?php

namespace Controllers\Configuration;

use \Centreon\Core\Form;

class ServicegroupController extends \Centreon\Core\Controller
{

    /**
     * List servicegroups
     *
     * @method get
     * @route /configuration/servicegroup
     */
    public function listAction()
    {
        // Init group
        $di = \Centreon\Core\Di::getDefault();
        $tpl = $di->get('template');

        // Load CssFile
        $tpl->addCss('dataTables.css')
            ->addCss('dataTables.bootstrap.css')
            ->addCss('dataTables-TableTools.css');

        // Load JsFile
        $tpl->addJs('jquery.dataTables.min.js')
            ->addJs('jquery.dataTables.TableTools.min.js')
            ->addJs('bootstrap-dataTables-paging.js');
        
        // Display page
        $tpl->display('configuration/servicegroup/list.tpl');
    }

    /**
     * 
     * @method get
     * @route /configuration/servicegroup/list
     */
    public function datatableAction()
    {
        echo \Centreon\Core\Datatable::getDatas(
            'servicegroup',
            $this->getParams('get')
        );

    }
    
    /**
     * Create a new servicegroup
     *
     * @method post
     * @route /configuration/servicegroup/create
     */
    public function createAction()
    {
        
    }

    /**
     * Update a servicegroup
     *
     *
     * @method put
     * @route /configuration/servicegroup/update
     */
    public function updateAction()
    {
        
    }
    
    /**
     * Update a servicegroup
     *
     *
     * @method get
     * @route /configuration/servicegroup/[i:id]
     */
    public function editAction()
    {
        // Init template
        $di = \Centreon\Core\Di::getDefault();
        $tpl = $di->get('template');
        
        $form = new Form('servicegroupForm');
        $form->addText('name', _('Service Group Name'));
        $form->addText('description', _('Service Description'));
        $radios['list'] = array(
            array(
              'name' => 'Enabled',
              'label' => 'Enabled',
              'value' => '1'
            ),
            array(
                'name' => 'Disabled',
                'label' => 'Disabled',
                'value' => '0'
            )
        );
        $form->addRadio('servicegroup_status', _("Status"), 'servicegroup_type', '&nbsp;', $radios);
        $form->addTextarea('comments', _('Comments'));
        $form->add('save_form', 'submit' , _("Save"), array("onClick" => "validForm();"));
        $tpl->assign('form', $form->toSmarty());
        
        // Display page
        $tpl->display('configuration/servicegroup/edit.tpl');
    }
}
