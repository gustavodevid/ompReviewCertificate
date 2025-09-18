{**
 * @file plugins/generic/reviewCertificate/templates/reviewStepHeader.tpl
 *
 * Copyright (c) 2024 Gustavo David Cesario
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Template que sobrescreve o cabeçalho do fluxo de avaliação para adicionar a aba de certificado.
 *
 * @author Gustavo David gustavo.cesariosilva15@gmail.com
 * @version 1.0
 * @date 2025-09-18
 *}
 
{extends file="layouts/backend.tpl"}


{block name="page"}

  <h1 class="app__pageHeading">
    {$pageTitle}
  </h1>

  <script type="text/javascript">
    // Attach the JS file tab handler.
    $(function() {ldelim}
      $('#reviewTabs').pkpHandler(
        '$.pkp.pages.reviewer.ReviewerTabHandler',
        {ldelim}
          reviewStep: {$reviewStep|escape},
          selected: {$selected|escape}
        {rdelim}
      );
    {rdelim});
  </script>


  <div id="reviewTabs" class="pkp_controllers_tab">
    <ul>
      <li><a href="{url op="step" path=$submission->getId() step=1}">{translate key="reviewer.reviewSteps.request"}</a></li>
      <li><a href="{url op="step" path=$submission->getId() step=2}">{translate key="reviewer.reviewSteps.guidelines"}</a></li>
      <li><a href="{url op="step" path=$submission->getId() step=3}">{translate key="reviewer.reviewSteps.download"}</a></li>
      <li><a href="{url op="step" path=$submission->getId() step=4}">{translate key="reviewer.reviewSteps.completion"}</a></li>

      {if ($reviewerConfirmed)}
      <li style="cursor: pointer;"><a class="ui-tabs-anchor" onclick="gerarPDF()">5. {translate key="plugins.generic.reviewCertificate.button"}</a></li>
      {/if}
    </ul>
  </div>
    
  <div id="container" style="display: none;">
    <div id="modal" style="
      position: fixed; 
      top: 0; 
      right: 0; 
      bottom: 0; 
      left: 0; 
      overflow: auto; 
      outline: 0; 
      z-index: 1050; 
      visibility: hidden; 
      display: none;">

      <div id="content" style="
        position: relative;
        margin: 10px;">

        <div id="modal-content" style="
          max-width: 100%;
          box-sizing: border-box;
          position: relative;
          z-index: 100;
          background-color: #fff; 
          box-shadow: 0 3px 9px rgba(0, 0, 0, 0.5); 
          border-radius: 0.3rem; 
          transform: scale(0.95);">

          <div id="modal-body" style="
            max-height: calc(100% - 100px); 
            overflow-y: auto;">

            {* Usei a versão simplificada com tabelas para garantir a geração do PDF *}
            <div id="certificadoModal">
                <table width="100%" style="border: 10px solid #00569e; height: 95%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 40px; text-align: center; vertical-align: top;">
                            <table width="100%" style="border: 0;">
                                <tr>
                                    <td style="width: 70%; text-align: center;">
                                        <h2 style="margin-right: 9px; font-family: sans-serif; color: #002b4f;">INSTITUTO FEDERAL DE EDUCAÇÃO CIÊNCIA</h2>
                                        <h2 style="font-family: sans-serif; color: #002b4f;">E TECNOLOGIA DA PARAÍBA</h2>
                                    </td>
                                    <td style="width: 30%; text-align: right;">
                                        <img src="{$ifpbLogoPath|escape}" style="width: 100px; height: auto;">
                                    </td>
                                </tr>
                            </table>
                            <div style="margin-top: 38px; text-align: center; font-family: sans-serif;">
                                <h3 style="font-weight: bold; font-size: 24px;">Declaração do Revisor Ad Hoc</h3>
                                <div style="padding-top: 10px; width: 80%; margin: 0 auto; text-align: justify; font-size: 18px; line-height: 1.6;">
                                    <p>
                                        Declaramos, para os devidos fins, que <strong>{$reviewerFullName|escape}</strong> desempenhou
                                        a função de avaliador(a) ad hoc do artigo científico identificado pelo código
                                        <strong>{$submissionId|escape}</strong>, a convite do Comitê Editorial da
                                        <strong>{$currentContext->getLocalizedName()|escape}</strong>, no dia {$dateCompletedBR|escape}.
                                    </p>
                                </div>
                                <h3 style="font-weight: bold; margin-top: 30px; font-size: 24px;">Ad Hoc Reviewer Statement</h3>
                                <div style="padding-top: 10px; width: 80%; margin: 0 auto; text-align: justify; font-size: 18px; line-height: 1.6;">
                                    <p>
                                        We now declare that <strong>{$reviewerFullName|escape}</strong> served
                                        as an ad hoc reviewer for the scientific article identified by the code
                                        <strong>{$submissionId|escape}</strong>, at the invitation of the Editorial Committee of the
                                        <strong>{$currentContext->getLocalizedName()|escape}</strong>, on {$dateCompletedUS|escape}.
                                    </p>
                                </div>
                                <div style="margin-top: 50px; text-align: right; margin-right: 40px; font-size: 16px;">
                                    <p>
                                        João Pessoa, Brasil/Brazil, {$dateCompletedBR|escape}
                                    </p>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 40px; text-align: center; vertical-align: bottom;">
                            <div style="text-align: center;">
                                {if $pressMasterSignature}
                                    <img src="{$pressMasterSignature|escape}" alt="Assinatura" style="width: 200px; height: auto;"><br>
                                {/if}
                                <strong>{$pressMasterFullName|escape}</strong><br>
                                <span style="font-size: 12px;">Diretor-Executivo da Editora IFPB/ Executive Director of IFPB Publishing House</span>
                            </div>
                            {if $pressLogoPath}
                                <div style="margin-top: 30px;">
                                    <img src="{$pressLogoPath|escape}" style="max-width: 150px; max-height: 70px; width: auto; height: auto;">
                                </div>
                            {/if}
                        </td>
                    </tr>
                </table>
            </div>
            
          </div> 
        </div> 
      </div> 
    </div> 
  </div> 

  <script src="https://rawgit.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
  <script>
    {literal}
    function gerarPDF() {
      var valorDoEditor = document.getElementById('certificadoModal');
      var options = {
        margin: 10,
        filename: 'documento.pdf',
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2 },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' },
        pagebreak: { mode: ['avoid-all'] }
      };
      html2pdf(valorDoEditor, options);
    }
    {/literal}
  </script>

{/block}