<?php

/**
 * @file plugins/generic/reviewCertificate/ReviewCertificatePlugin.inc.php
 *
 * Copyright (c) 2024 Gustavo David Cesario
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class ReviewCertificatePlugin
 * @brief Plugin para adaptar e fornecer certificados de avaliação para o OMP.
 *
 *
 * @author Gustavo David gustavo.cesariosilva15@gmail.com
 * @version 1.0
 * @date 2025-09-18
 */

import('lib.pkp.classes.plugins.GenericPlugin');
class ReviewCertificatePlugin extends GenericPlugin
{
	/**
     * @copydoc Plugin::register()
     */
	function register($category, $path, $mainContextId = NULL)
	{
		$success = parent::register($category, $path);

		if ($success && $this->getEnabled()) {
			HookRegistry::register(
				'TemplateResource::getFilename',
				array($this, '_overridePluginTemplates')
			);
		}
		return $success;
	}
	
	 /**
     * Sobrescreve templates do sistema para adicionar novas funcionalidades.
     * @param string $hookName Nome do Hook.
     * @param array $args Argumentos do Hook.
     * @return bool
     */
	function _overridePluginTemplates($hookName, $args)
	{
		$templatePath = $args[0];
		$templateMgr = TemplateManager::getManager();
		
		// Alvo 1: Adicionar a aba "Meus certificados" no painel principal de submissões.
		if ($templatePath === 'lib/pkp/templates/dashboard/index.tpl') {
			error_log('found template.');

			$reviewedSubmissions = $this->fetchReviewedSubmissions();

			if (!$this->hasReviewerRole()) {

				if ($reviewedSubmissions) {
					$args[0] = 'plugins/generic/reviewCertificate/' .
						'templates/index.tpl';

					$templateMgr->assign([
						'reviewedSubmissions' => $reviewedSubmissions
					]);
					return true;
				}
			}
			return;
		}

		// Alvo 2: Adicionar a aba "Certificado" no fluxo de trabalho da avaliação.
		if ($templatePath === 'lib/pkp/templates/reviewer/review/reviewStepHeader.tpl') {

			$submission = $templateMgr->get_template_vars('submission');
			$reviewData = $this->fetchReviewData($submission);
			if ($reviewData) {
				$args[0] = 'plugins/generic/reviewCertificate/' .
					'templates/reviewStepHeader.tpl';
				$templateMgr->assign($reviewData);
				return true;
			}
		}

		return false;
	}

	/**
	 * hasReviewerRole, itera sobre os cargos do usuário procurando pelo cargo de avaliador.
	 *
	 * verifica se o usuário logado tem o cargo Avaliador, se tiver ele retorna false, se não, retorna true.
	 *
	 * @return boolean
	 **/
	private function hasReviewerRole()
	{
		$userGroupDao = DAORegistry::getDAO('UserGroupDAO');
		$request = $this->getRequest();

		$loggedInUserId = $request->getUser()->getId();
		$contextId = $request->getContext()->getId();

		$userGroupAssignments = $userGroupDao->getByUserId($loggedInUserId, $contextId)->toArray();

		foreach ($userGroupAssignments as $userGroup) {
			$groupName = trim(mb_strtolower($userGroup->getLocalizedName()));

			if ($groupName === 'avaliador') {
				return true;
			}
		}

		return false;
	}

	/**
	 * fetchReviewedSubmissions, filtra as revisões feitas por um usuário e retorna ID e TITLE das submissões avaliadas por ele.
	 *
	 * resgata o id do usuário logado e as revisões feitas por ele. Retorna as submissões relacionadas caso encontre, retorna false caso não encontre.
	 *
	 * @return array|boolean
	 **/
	private function fetchReviewedSubmissions()
	{
		$reviewAssignmentDao = DAORegistry::getDAO('ReviewAssignmentDAO');
		$submissionDao = DAORegistry::getDAO('SubmissionDAO');

		$request = $this->getRequest();

		$loggedInUserId = $request->getUser()->getId();
		$reviewAssignmentsByUser = $reviewAssignmentDao->getByUserId($loggedInUserId);
		$result = [];

		$reviewAssignmentsByUser = array_filter(
			$reviewAssignmentsByUser,
			function ($assignment) use ($loggedInUserId) {
				return $assignment->getReviewerId() === $loggedInUserId
					&& $assignment->getDateConfirmed() !== NULL
					&& $assignment->getDateCompleted() !== NULL;
			}
		);

		if (!$reviewAssignmentsByUser) {
			error_log('submissions revieweds not found!');
			return false;
		}

		foreach ($reviewAssignmentsByUser as $reviewAssignment) {
			$submissionId = $reviewAssignment->getSubmissionId();
			$submission = $submissionDao->getById($submissionId);

			if (!$submission) {
				continue; 
			}

			$publication = $submission->getCurrentPublication();
			if (!$publication) {
				continue;
			}

			$title = $publication->getLocalizedTitle();
			
			$result[] = [
					'id' => $submission->getId(),
					'title' => $title,
					'reviewData' => $this->fetchReviewData($submission)
			];
		}

		return $result;
	}

	/**
     * Busca os dados detalhados para um certificado de uma submissão específica.
     * @param Submission $submission O objeto da submissão.
     * @return array|false Um array com os dados do certificado ou false.
     */
	private function fetchReviewData($submission)
    {
        // id do artigo
        $submissionId = $submission->getId();
        $request = $this->getRequest();

        // DAOs necessários
        $reviewAssignmentDao = DAORegistry::getDAO('ReviewAssignmentDAO');

        // checar se há revisões confirmadas feitas por este usuário
        $loggedInUserId = $request->getUser()->getId();
        $loggedInUserFullName = $request->getUser()->getFullName();
        $reviewAssignments = $reviewAssignmentDao->getBySubmissionId($submissionId);

        $reviewerConfirmedAssignments = array_filter(
            $reviewAssignments,
            function ($assignment) use ($loggedInUserId) {
                return $assignment->getReviewerId() === $loggedInUserId
                    && $assignment->getDateConfirmed() !== NULL;
            }
        );

        $reviewerConfirmed = count($reviewerConfirmedAssignments) > 0;
        if (!$reviewerConfirmed) return false;

        // --- INÍCIO DAS CORREÇÕES ---

        // CORREÇÃO 1: Obter a editora (Press) da forma correta
        $press = $request->getContext();
        
        // CORREÇÃO 2: Usar o objeto $press diretamente e corrigir o caminho do logo
        $pressId = $press->getId();
        $pressLogo = $press->getLocalizedPageHeaderLogo()['uploadName'];
        if ($pressLogo === NULL) {
            $pressLogoPath = NULL;
        } else {
            // OMP usa a pasta 'journals' para arquivos públicos por compatibilidade
            $pressLogoPath = '/public/journals/' . $pressId . '/' . $pressLogo;
        }
        
        // --- FIM DAS CORREÇÕES ---

        $ifpbLogoPath = '/' . $this->getPluginPath() . '/resources/logo_ifpb.png';

        // Você renomeou a variável, o que é bom para consistência.
        $pressMasterFullName = "Ademar Gonçalves da Costa Junior"; 
        $pressMasterSignatureSrc = $this->getPluginPath() .
            '/resources/signature.png';
        $pressMasterSignature = $this->getSignature($pressMasterSignatureSrc);

        // data da última revisão confirmada
        $lastReviewerAssignment = end($reviewerConfirmedAssignments);
        $dateCompleted = explode(
            '-',
            substr($lastReviewerAssignment->getDateCompleted(), 0, 10)
        );

        $dateCompletedFormatted_PT_BR = $this->formatDateCompleted($dateCompleted, 'pt_BR');
        $dateCompletedFormatted_EN_US = $this->formatDateCompleted($dateCompleted, 'en_US');

        return
            [
                'reviewerConfirmed' => $reviewerConfirmed,
                'reviewerFullName' => $loggedInUserFullName,
                'submissionId' => $submissionId,
                'dateCompletedBR' => $dateCompletedFormatted_PT_BR,
                'dateCompletedUS' => $dateCompletedFormatted_EN_US,
                'pressLogoPath' => $pressLogoPath,
                'ifpbLogoPath' => $ifpbLogoPath,
                'pressMasterFullName' => $pressMasterFullName,
                'pressMasterSignature' => $pressMasterSignature
            ];
    }

	/**
     * Formata um array de data [Y, m, d] para uma string textual.
     * @param array $dateCompleted Array com ano, mês e dia.
     * @param string $locale Localização ('pt_BR' ou 'en_US').
     * @return string Data formatada.
     */
	private function formatDateCompleted($dateCompleted, $locale)
	{
		$month = $dateCompleted[1];
		$monthInFull = '';
		$months = [];

		if ($locale == 'pt_BR') {
			$months = [
				"janeiro",
				"fevereiro",
				"março",
				"abril",
				"maio",
				"junho",
				"julho",
				"agosto",
				"setembro",
				"outubro",
				"novembro",
				"dezembro"
			];
		} else {
			$months = [
				"january",
				"february",
				"march",
				"april",
				"may",
				"june",
				"july",
				"august",
				"september",
				"october",
				"november",
				"december"
			];
		}

		if ($month >= 1 && $month <= 12) {
			$monthInFull = $months[$month - 1];
		}

		if ($locale == 'pt_BR') {
			return $dateCompleted[2] . ' de ' . $monthInFull . ' de ' . $dateCompleted[0];
		} else {
			return $monthInFull . ' ' . $dateCompleted[2] . ', ' . $dateCompleted[0];
		}
	}

	/**
     * Converte uma imagem em uma string base64 para embutir no HTML.
     * @param string $signatureSrc Caminho para o arquivo de imagem.
     * @return string Imagem formatada em base64.
     */
	private function getSignature($signatureSrc)
	{
		$signatureData = base64_encode(file_get_contents($signatureSrc));
		return 'data:image/png;base64,' . $signatureData;
	}

	/**
     * @copydoc Plugin::getDisplayName()
     */
	function getDisplayName()
	{
		return __('plugins.generic.reviewCertificate.displayName');
	}

	/**
     * @copydoc Plugin::getDescription()
     */
	function getDescription()
	{
		return __('plugins.generic.reviewCertificate.description');
	}
}
